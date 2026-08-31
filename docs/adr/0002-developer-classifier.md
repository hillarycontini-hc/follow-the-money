# ADR 0002: Classify developers by occupation, and ship the sensitivity table with the finding

**Status:** accepted
**Date:** 2026-08-31

## Context

This project's headline finding is about the 2019 Los Angeles ordinance banning campaign
contributions from real-estate developers. The ordinance was adopted on 2019-12-04 but
written so that it did not bind until after the March 2022 primary — and the filings
appear to show money moving through that gap.

Testing that claim requires deciding who counts as a developer. The dataset offers two
candidate fields, and neither is clean.

## Decision

**Classify on `Contrib Occupation`, not `Contrib Employer`. Publish four definitions and
ship the sensitivity table alongside the finding.**

`is_developer_standard` is the certified definition. Three others — narrow, broad,
broadest — exist as macros and are exercised in `analyses/developer_sensitivity.sql`.

## Rationale

### Why not employer

Entity resolution over `Contrib Employer` is a month of work with no payoff here:

- 119,182 distinct values, normalising to 107,886 — a **9.5% reduction**.
- **73,575 employers appear exactly once**, holding 27.7% of dollars.
- The top 1,000 employers reach only 33.8% of dollars.

There is no head to attack. The distribution is almost all tail, so normalisation buys
proportionally nothing. Occupation has 29,219 values with a usable head, reproduces the
finding on its own, and adding employer matching moves totals by roughly 12% while
leaving the shape unchanged.

### Why the exclusions are the substance

"Developer" is ambiguous between real estate and software. "Development" is ambiguous
between real estate and nonprofit fundraising. A naive `%develop%` match sweeps in
`SOFTWARE DEVELOPER` (133 rows), `BUSINESS DEVELOPMENT`, `DEVELOPMENT DIRECTOR`,
`DIRECTOR OF DEVELOPMENT` and `LANDSCAPE ARCHITECT`. The exclusion list is not
housekeeping; it is most of what the classifier does.

### Why four definitions rather than one

Because the answer moves, and in one direction it moves enough to change the conclusion.

| Year | narrow | standard | broad | broadest |
|---|---|---|---|---|
| 2021 | 2.82× | 2.97× | 3.01× | 2.93× |
| 2022 | 3.55× | 4.04× | 4.10× | 4.00× |
| 2023 | 0.64× | 1.14× | 1.19× | 1.14× |
| **2024** | **0.69×** | **1.55×** | **1.56×** | **1.49×** |
| 2025 | 0.23× | 1.39× | 1.48× | 1.41× |

(Ratios against a 2016–2019 baseline. All exclude self-loan mirrors.)

**The spike is robust.** 2021 and 2022 run well above baseline under every definition.
No reasonable way of drawing the boundary makes it go away.

**The collapse is not.** It does not merely weaken — it reverses. Under the narrow
definition 2024 sits at 0.69× of baseline, which reads as the ban taking effect. Under
the standard and broad definitions the same year sits at 1.55× and 1.56×: *above*
baseline, which reads as no effect at all.

The narrow definition only matches occupations that say "developer" in those words. What
it is really detecting in 2024 is that fewer people wrote that particular job title on a
disclosure form after it became legally salient — not that the money stopped.

## Publication rule

Ship the 2021–22 spike as a finding. Ship the post-ban collapse as **"consistent with,
but not established by, this data"**, with the sensitivity table attached.

This is the rule the project would have broken without measuring. The research notes in
`research/summary.md` read the 2024 fall as "the ban finally taking effect" and called it
the strongest available finding. Half of it holds. The half that does not is an artefact
of a classifier choice nobody had written down.

## Consequences

- The certified `developer_contributions` metric uses one definition, so a number quoted
  from it is reproducible.
- Anyone changing that definition changes a macro that four analyses depend on, and the
  sensitivity table will show what moved.
- The finding ships with its own uncertainty attached, which is less satisfying and more
  honest.
