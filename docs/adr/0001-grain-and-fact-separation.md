# ADR 0001: One flat file, four fact grains

**Status:** accepted
**Date:** 2026-08-31

## Context

The source is a single 418,748-row table where every row looks like a contribution. It
is not one thing. Four different kinds of disclosure are stacked in it, distinguished
only by a `Schedule` letter and a `Contribution Type` string:

| Schedule | Rows | What it actually is |
|---|---|---|
| A | 387,658 | Monetary contributions |
| B | 10,748 | Loans received |
| C | 10,197 | Non-monetary (in-kind) contributions |
| I | 10,145 | Miscellaneous increases to cash |

Summing the `Contribution Amount` column across all of them returns **$761,997,407**,
and that number is wrong in four independent ways at once.

There is a second problem underneath the first. There is no natural key. Grouping on all
30 source columns still leaves **1,395 duplicate rows worth $17,802,401**, of which
$14.5M is a single contributor — three identical $4,000,000 rows on the same day.

## Decision

**Separate the grains into four facts, and give the fact a surrogate key that preserves
legitimate duplicates.**

- `fct_contribution` — one row per itemised monetary or in-kind contribution line.
- `fct_loan_snapshot` — Schedule B, modelled explicitly as a **periodic snapshot**.
- `fct_public_financing` — Schedule I.
- `fct_unitemized_aggregate` — period aggregates of sub-threshold giving.

The key is a hash of the business columns plus an **occurrence index** within that hash
group, assigned at ingest.

## Rationale

**Schedule B is not a transaction fact.** 9,750 of its 10,748 rows carry an amount of
$0.00. They are carry-forwards re-declaring an outstanding loan in every subsequent
filing period until it is repaid — one loan appears across 19 periods, another across 17
and is still running in 2026. The dollar total is safe to sum; the row count is not.
Anyone asking "how many loans were made?" must count distinct lender/committee pairs.
Modelling this as a transaction fact would make that error invisible.

**Schedule I is not miscellaneous.** This project's own research notes recorded it as an
undifferentiated grab-bag whose contents could not be attributed, and concluded that
public matching funds were not identifiable in this dataset. That was wrong. 91.8% of
Schedule I — $50.1M of $54.6M — is explicitly labelled matching funds, paid by the City
of Los Angeles, the LA City Ethics Commission, or the LA City Treasury. It is taxpayer
money flowing to candidates, which is a materially different thing from a donation.

**The duplicates are not all errors.** Same-day instalments and the "and Affiliated
Entities" disclosure convention both produce byte-identical rows that represent distinct
real events. Deduplicating on content would silently delete $17.8M of genuine filings.
Distinguishing them by occurrence index keeps them addressable without pretending we can
tell which twins are errors — because from the data alone, we cannot.

## What we got wrong first

The unitemized rows were initially excluded from the contributions total on the
assumption that they summarise the itemised rows beside them and would double-count.

Measuring disproved it. Across the 6,963 committee-periods that carry an unitemized
line, the **median aggregate is 1.5% of that period's itemised total**, and the largest
aggregates of all belong to a committee reporting **$0.00 itemised** in those periods —
including a single $16,133,477 line. They are contributions below the itemisation
threshold: real, additional money, disclosed in bulk because no individual gift was
large enough to require naming a donor.

They stay in their own fact, because "no donor" is a different grain. But the certified
`contributions_total` metric adds them back, and the earlier framing understated
receipts by **$174.8M**.

## Consequences

- No single table answers "how much money moved". That is correct, and the semantic
  layer is where the composition happens.
- `contributions_total` spans two facts at two grains, so it must be a derived metric.
- `avg_contribution` must divide by the itemised total, not the full one: aggregates
  carry dollars but no contribution lines.
- Anyone adding a fifth schedule must decide its grain before writing SQL, which is the
  point.
