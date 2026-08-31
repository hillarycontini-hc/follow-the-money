# Follow the Money

A governed dimensional model over 418,748 Los Angeles city campaign-contribution
filings, 2001–2026.

Somewhere in this project's research notes is a markdown table with a parenthetical
hand-written into one cell:

> 2023 · $107,367,865 *(Caruso self-loan — exclude)*

That parenthetical is a semantic layer. It encodes a real and necessary correction, it is
correct, and it protects exactly one number in exactly one table — until someone copies
the query, or refreshes the data, or writes a new one.

This repository is that footnote, rebuilt as something a query cannot bypass.

```
                       naive          governed
developer money, 2023  $107,478,000   $219,851      489×
```

The naive figure does not merely inflate. It **inverts the finding** — it reports that
developer money exploded in the year after Los Angeles banned developer contributions.
The largest self-described real-estate developer in the dataset is a candidate lending
his own campaign $107M, disclosed once as a contribution and again as a loan.

---

## Run it

```bash
uv sync
uv run dbt deps
uv run python pipelines/socrata_contributions.py   # ~15 min, 418,748 rows
uv run dbt build
uv run mf query --metrics contributions_total --group-by metric_time__year
```

No warehouse, no containers, no account. DuckDB in a single file, `profiles.yml` in the
repo. Python is pinned to 3.12 and dbt-core to 1.11.14 — [both pins are
load-bearing](#toolchain-pins).

## The audit ladder

Every step removes money a reasonable person would have summed.

| | | Running total | Removed |
|---|---|---|---|
| 1 | Sum every amount in the file | $761,997,407 | |
| 2 | Less Schedule B — loans are borrowed, not given | $634,685,271 | −$127,312,136 |
| 3 | Less Schedule I — 91.8% is public matching funds | $580,115,802 | −$54,569,469 |
| 4 | Less self-loan mirrors — the same money, twice | $470,020,847 | −$110,094,955 |

**$292M of difference**, and none of it is rounding. Step 4 removes almost as much as
steps 2 and 3 combined, and it is the one nobody thinks of.

`analyses/naive_vs_governed.sql` reproduces this.

## What is in here

```
pipelines/          dlt ingest from Socrata, with reconciliation
models/staging/     typed, validated, quarantined — nothing dropped silently
models/intermediate/
models/marts/certified/   contracted, versioned, tested
models/marts/local/       heuristics, private, may not be depended on
scripts/            CI enforcement of the certification boundary
docs/adr/           why, not what
research/           the working notes this began as — see ADR 0004
```

### Four fact grains in one flat file

The source looks like one table of contributions. It is four things wearing the same
column names:

- **`fct_contribution`** — itemised monetary and in-kind lines. One row per disclosure.
- **`fct_loan_snapshot`** — Schedule B, a *periodic snapshot*: 9,750 of 10,748 rows are
  $0.00 carry-forwards re-declaring an outstanding loan each period. One loan spans 19
  filing periods. Sum the dollars; never count the rows.
- **`fct_public_financing`** — Schedule I. Recorded in the research notes as an
  unattributable grab-bag. It isn't: 91.8% is public matching funds paid by the City.
- **`fct_unitemized_aggregate`** — sub-threshold giving with no donor attached.

### `dim_committee` is Type 2, and it matters

Committee `1319104` files under three names across three cycles — supporting one
candidate in 2013, opposing a different one in 2024. UTLA's `1393480` files under seven.
A Type 1 dimension would report 2013 mayoral money as raised by a 2024 committee opposing
a council member.

### There is no natural key

Grouping on all 30 source columns still leaves **1,395 duplicate rows worth
$17,802,401** — and they are not all errors. Same-day instalments and the "and Affiliated
Entities" disclosure convention produce legitimate twins. They are preserved by
occurrence index and flagged, because deduplicating on content would delete $17.8M of
real filings.

## Governance: two tiers and one rule

**A certified model may not reference a sandbox model.**

Enforced twice — by dbt's `access: private` at parse time, and by
`scripts/check_certification_boundary.py` against the compiled manifest, so the guarantee
survives a config edit that loosens access.

`local__ie_target` is the deliberate example of work that stays uncertified forever. LA
committee names are literal enough to parse an IE's target off the name, which is
genuinely useful — and not certifiable, because it resolves 101 of 210 committees but
only **18.8% of IE dollars**. The gap is not random: the biggest committees have the
blandest names, and NEA Advocacy Fund's $80.2M names no target at all.

A project where everything is certified has not made this trade-off. It has refused the
fast lane and called that governance. See [ADR 0003](docs/adr/0003-certified-and-sandbox-tiers.md).

## The pipeline has no CDC to lean on

Both obvious watermarks are traps. `:updated_at` and `:created_at` are identical for
every row and move on every refresh — on 2026-08-30 every row read `13:38:40Z`; the next
day every row read `15:59:06Z`, **including a contribution dated 2003**. The publisher
truncates and reloads, so `:id` is regenerated too.

So: watermark on the business date, re-read a 120-day trailing window because CA460
filings are amended after their period closes, and merge on a content key so a re-read
converges instead of duplicating. CI proves that by running the load twice and comparing
a fingerprint.

## What I got wrong

Five claims in this project were confident, plausible, and false. Each was caught by
measuring or by running it somewhere else -- none by doubting.

| Claim | Reality |
|---|---|
| Unitemized rows summarise the itemised rows and would double-count | Median aggregate is **1.5%** of its period's itemised total; the largest belong to a committee with $0.00 itemised. Additional money. Excluding it understated receipts by **$174.8M** |
| Self-loan mirrors are separated from everything else by a clean gap (nearest excluded 0.4117) | The distribution is **continuous**: 0.996401 below, 1.000309 above. The rule survived; its justification did not |
| Developer money collapsed after the ban took effect | Reverses with the definition: **0.69× baseline** narrow, **1.55× broad**. Opposite conclusions |
| Schedule I is an unattributable grab-bag | **91.8% is labelled public matching funds** with a named payer |
| The landing table has a stable shape | It was **inferred from the data**, so a full load and a one-year backfill produced *different columns*. Local runs were green; CI's bounded window failed to compile |

The first load of the pipeline also reported success having written 418,716 of 418,748
rows. The 32 missing were 8 with dates outside any plausible range and 24 with no date at
all, silently excluded by the watermark predicate. That is why reconciliation is now part
of the pipeline rather than a test someone might not run.

The schema bug is the one worth dwelling on, because a comment in this repository already
described the mechanism — "the landing table's shape is a function of the data" — and it
was still filed as a quirk of one dead column rather than as a fault. Writing an
observation down is not the same as acting on it. It took an environment that disagreed
with mine to make it fail, which is the entire argument for running the thing somewhere
other than the machine that built it.

## What this data cannot answer

Schedules A/B/C/I are money **received**. Expenditures — Schedules D/E/F — are a separate
dataset and are not here. Any figure about spending, advertising, or cost-per-vote is
sourced to outside reporting and must never be attributed to this repository.

Contributor names are free text and are not resolved to people. `contributor_count`
counts name strings.

## Toolchain pins

`pip install dbt-core` fails on this machine, and the reason is not the obvious one.
dbt-core 1.12.x hard-requires `dbt-core-experimental-parser`, a Rust package that has been
sdist-only since 2.0.0a5 — so it needs cargo and MSVC on **every** Python version, not
just new ones. 1.11.14 has no compiled dependency.

Python 3.12 rather than 3.14 because dbt-core 1.11.14 *installs* on 3.14 and then crashes
on import with `mashumaro.exceptions.UnserializableField`, under PEP 649 deferred
annotations.

Targeting dbt 1.11 today; dbt Fusion's DuckDB adapter is beta as of August 2026.

## Portability

DuckDB is the right size for 418,748 rows and saying so is not an apology — this fits in
RAM, and reaching for Spark would announce a misunderstanding of the problem. Local
DuckDB with deployment to a warehouse is ordinary practice.

What ports unchanged: the dimensional model, the metric definitions, the contracts, the
tests, and the certification boundary. What does not: warehouse operations — clustering,
cost, RBAC, `MERGE` at scale, concurrency. Those are not demonstrated here and this
README will not pretend otherwise.

`docs/powerbi/` expresses the same certified metrics as a Power BI semantic model, since
the vocabulary differs more than the ideas do.

---

Data: [LA City Ethics Commission via Socrata `m6g2-gc6c`](https://data.lacity.org/d/m6g2-gc6c),
CC0. Refreshed daily; `data.csv` is not committed and the pipeline regenerates it.
