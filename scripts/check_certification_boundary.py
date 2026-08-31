"""Fail the build if a certified model depends on an uncertified one.

This is the governance argument expressed as a rule rather than a paragraph.

The project runs two tiers on purpose. Certified models are contracted, versioned and
pinned by tests; changing what they mean requires changing a test, which makes the
change deliberate and reviewable. Sandbox models are heuristics -- regexes over
committee names, exploratory cuts -- and they are allowed to be fast, wrong and
frequently rewritten, because that is what makes them useful.

The tiers only mean anything if the boundary holds in one direction: sandbox work may
build on certified models, never the reverse. Documentation cannot enforce that. dbt's
`access: private` prevents the reference at parse time, and this check re-asserts it
against the compiled manifest so the guarantee survives a config edit that quietly
loosens access.

Run after `dbt parse` or any command that writes target/manifest.json.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

MANIFEST = Path(__file__).resolve().parents[1] / "target" / "manifest.json"

CERTIFIED_GROUP = "certified"
SANDBOX_GROUP = "sandbox"
SANDBOX_PREFIX = "local__"


def load_manifest() -> dict:
    if not MANIFEST.exists():
        sys.exit(
            f"manifest not found at {MANIFEST}. Run `dbt parse` or `dbt build` first."
        )
    return json.loads(MANIFEST.read_text(encoding="utf-8"))


def is_sandbox(node: dict) -> bool:
    """A model is sandbox if it says so by group or by name.

    Both are checked because they fail differently. The group is authoritative but can
    be dropped by an edit to dbt_project.yml; the naming convention is visible in every
    ref() a reader encounters. Requiring agreement means a model cannot drift into the
    wrong tier silently.
    """
    return (
        node.get("group") == SANDBOX_GROUP
        or node.get("name", "").startswith(SANDBOX_PREFIX)
    )


def is_certified(node: dict) -> bool:
    return node.get("group") == CERTIFIED_GROUP


def main() -> int:
    manifest = load_manifest()
    nodes = {
        uid: node
        for uid, node in manifest.get("nodes", {}).items()
        if node.get("resource_type") == "model"
    }

    violations: list[tuple[str, str]] = []
    mislabelled: list[str] = []

    for uid, node in nodes.items():
        name = node.get("name", uid)

        # A model named local__* that is not in the sandbox group, or vice versa, is a
        # labelling error. Catch it here rather than letting the two signals disagree.
        named_sandbox = name.startswith(SANDBOX_PREFIX)
        grouped_sandbox = node.get("group") == SANDBOX_GROUP
        if named_sandbox != grouped_sandbox:
            mislabelled.append(
                f"{name}: name says sandbox={named_sandbox}, "
                f"group says sandbox={grouped_sandbox}"
            )

        if not is_certified(node):
            continue

        for parent_uid in node.get("depends_on", {}).get("nodes", []):
            parent = nodes.get(parent_uid)
            if parent and is_sandbox(parent):
                violations.append((name, parent.get("name", parent_uid)))

    if mislabelled:
        print("Models whose name and group disagree about their tier:", file=sys.stderr)
        for line in mislabelled:
            print(f"  - {line}", file=sys.stderr)

    if violations:
        print(
            "\nCertified models may not depend on sandbox models.\n"
            "A certified number must not rest on a heuristic:",
            file=sys.stderr,
        )
        for child, parent in violations:
            print(f"  - {child} depends on {parent}", file=sys.stderr)
        return 1

    if mislabelled:
        return 1

    certified = sum(1 for n in nodes.values() if is_certified(n))
    sandbox = sum(1 for n in nodes.values() if is_sandbox(n))
    print(
        f"certification boundary intact: "
        f"{certified} certified, {sandbox} sandbox, 0 violations"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
