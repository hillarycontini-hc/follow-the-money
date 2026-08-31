"""Print a stable fingerprint of the loaded contributions table.

Used by CI to prove the pipeline is idempotent: run the load twice, fingerprint either
side, compare. Idempotency is the property most often claimed and least often
demonstrated, and for a merge on a content key it is the entire design -- a re-read of
an amended filing period has to converge on the same rows rather than accumulate copies
of them.

The fingerprint deliberately ignores the ingest timestamp. That column changes on every
run by construction, and including it would make the check pass only when the pipeline
did nothing at all.
"""

from __future__ import annotations

import hashlib
import sys
from pathlib import Path

import duckdb

DATABASE = Path(__file__).resolve().parents[1] / "followthemoney.duckdb"


def main() -> int:
    if not DATABASE.exists():
        print(f"database not found at {DATABASE}", file=sys.stderr)
        return 1

    con = duckdb.connect(str(DATABASE), read_only=True)

    row_count, key_digest = con.execute(
        """
        select
            count(*),
            md5(string_agg(_content_key, '|' order by _content_key))
        from raw.contributions
        """
    ).fetchone()

    # A content key encodes the business columns, so agreeing on the full set of keys is
    # agreeing on the full contents -- without hashing every column of every row.
    fingerprint = hashlib.blake2b(
        f"{row_count}:{key_digest}".encode("utf-8"), digest_size=16
    ).hexdigest()

    print(f"{row_count}:{fingerprint}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
