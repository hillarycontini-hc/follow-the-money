# ADR 0003: Two tiers, and a rule that stops the fast one leaking into the slow one

**Status:** accepted
**Date:** 2026-08-31

## Context

A governed model and a fast local one are usually presented as a choice. They are not.
The failure modes sit on opposite sides:

- Govern everything, and the central definition becomes a bottleneck. People route
  around it, and the governance describes a model nobody uses.
- Govern nothing, and every consumer invents their own definition. In this dataset that
  is not a stylistic problem — a naive `SUM` of the amount column is wrong by
  **$292 million**, and it is wrong in a way that looks entirely plausible.

The trade-off is real, so the model has to make a decision rather than pick a side.

## Decision

**Two tiers, with the boundary enforced by CI rather than by convention.**

| | Certified | Sandbox |
|---|---|---|
| Group | `certified` | `sandbox` |
| Access | `public` | `private` |
| Contracts | enforced | none |
| Test severity | error | warn |
| Naming | `fct_*`, `dim_*` | `local__*` |
| Changing it | requires changing a pinned test | free |

**The rule: a certified model may not reference a sandbox model.** Sandbox work may
build on certified models; never the reverse.

That rule is enforced twice. dbt's `access: private` blocks the reference at parse time.
`scripts/check_certification_boundary.py` re-asserts it against the compiled manifest, so
the guarantee survives a config edit that quietly loosens access — and additionally fails
if a model's name and its group disagree about which tier it is in.

## Rationale

The tiering only has meaning if it is directional. If a certified metric can quietly
depend on a regex over committee names, then "certified" describes a folder, not a
guarantee. Conversely, if sandbox models cannot use certified facts, the fast lane is
useless and people will work outside the project entirely — which is the bottleneck
failure in a different costume.

Enforcement had to be mechanical because the failure is silent. Nobody sets out to base a
published figure on a heuristic; it happens one `ref()` at a time, each individually
reasonable. A prose convention catches none of them. A build failure catches all of them.

The mechanism proved itself during construction: an intermediate model was initially left
outside any group, and dbt refused to let `fct_contribution` reference it. The rule fired
on the first real opportunity, before any code was written that depended on it.

## The deliberate example

`local__ie_target` stays uncertified permanently, and that is the point of it.

LA committee names are unusually literal — "Neighbors for a Safer and Cleaner LA,
Opposing Karen Bass" — so the candidate an independent-expenditure committee targets can
often be read straight off the name. Genuinely useful. Not certifiable:

- It resolves a target for **101 of 210** IE committees.
- Those committees hold **$54.4M of $289.1M** in IE dollars — **18.8%**.

The gap is not random. The largest committees have the blandest names: NEA Advocacy Fund
alone holds $80.2M and names no target at all. Any share computed from this model
understates exactly the committees whose money matters most, in a direction a reader
could not guess.

So it ships, labelled, in the fast lane, carrying an explicit `source_tier` column so the
tier travels with the result rather than living in documentation nobody opens.

**A project where everything is certified has not made this trade-off. It has just
refused the fast lane and called that governance.**

## Consequences

- Adding a certified model means writing a contract and a test. That friction is
  intentional and should stay noticeable.
- Sandbox models can be wrong. They are allowed to be wrong. They may not be quoted.
- The boundary check runs on every push, so loosening it is a visible act in a diff
  rather than a quiet one.
- At six certified models the certification cost is trivial. At two hundred it would need
  delegation to domain owners, and this ADR would need revisiting — the current scheme
  assumes one maintainer can review every certified change.
