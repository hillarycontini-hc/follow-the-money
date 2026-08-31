# ADR 0004: Fast, unreliable research is allowed to exist — it is not allowed to publish

**Status:** accepted
**Date:** 2026-08-31

## Context

Before any of this model existed, the domain research for this project was done by seven
agents working in parallel, each writing its own notes. It was fast, and the throughput
was genuinely useful: seven topics covered at once, with citations.

A synthesis pass then checked those notes against primary sources. It found that several
confident, quotable claims were wrong:

- Quotations attributed to a named U.S. Attorney and a named FBI Assistant Director
  **that do not appear** in the DOJ release they were credited to.
- An enforcement summary that omitted **more than a third of the money** and the most
  prominent name involved.
- A dollar figure attached to the wrong entity — a fine on one party reported as the sum
  another party had sought.
- An automated re-parse of an election canvass whose column headers are printed as
  vertical ASCII, which **swapped two races and would have reported the losing candidates
  as winners.**

All of it is recorded, with dates and source URLs, in `research/summary.md`.

The tempting conclusion is "do not use fast parallel research." That is the wrong lesson,
and acting on it would have cost the project most of what it knows.

## Decision

**Fast, uncertified work is legitimate and stays. It is labelled, it is separated from
certified work by a rule the build enforces, and it may not be the basis of a published
number.**

Concretely:

1. `research/` remains in the repository, unedited, with a README stating plainly that it
   is a working document, that claims marked unverified are unverified, and that the
   corrections table records **research errors, not allegations** about the people named.
2. Derived and heuristic fields carry an explicit `source_tier` (`certified` / `derived`
   / `unverified`) so the tier travels with the value.
3. The certified/sandbox boundary of [ADR 0003](0003-certified-and-sandbox-tiers.md) is
   what makes (2) more than a label: a certified model cannot reference a sandbox one,
   and CI fails if it tries.

## Rationale

Seven agents in parallel is maximum local speed with zero governance. Throughput was
excellent and trustworthiness was zero until something checked. That is not an argument
against speed — it is a precise description of what the fast lane is for, and of what it
must never be allowed to do on its own.

The same shape recurred repeatedly while building this model, which is why the ADR
generalises beyond the research folder:

- A prior analysis carried a **"clean gap" between self-loan mirrors and everything
  else**, quoting a nearest-excluded ratio of 0.4117. Measuring found the distribution is
  continuous: 0.996401 below and 1.000309 above. The rule survived; its stated
  justification did not.
- The unitemized rows were documented as **period summaries that would double-count**.
  Measuring found the median aggregate is 1.5% of its period's itemised total, and the
  largest belong to a committee with no itemised giving at all. They are additional
  money. The claim was backwards, and acting on it understated receipts by $174.8M.
- The **post-ban collapse** in developer money was recorded as the strongest available
  finding. It reverses depending on how "developer" is defined. See
  [ADR 0002](0002-developer-classifier.md).

In every case the error was confident, plausible, and would have survived review by
someone who did not run the query. What caught them was not scepticism about the source.
It was a measurement, and a place for the result to fail loudly.

## Consequences

- Nothing in `research/` is cited by a certified model. It informs what to build; it does
  not supply values.
- Claims in this repository that rest on a heuristic say so at the point of use, not in a
  footnote.
- The corrections table stays in its original form. Rewriting it into something more
  flattering would destroy the only thing that makes it credible — that it is a genuine
  internal working document, with dates and URLs, written before anyone thought of
  showing it to a reader.
- This ADR will need updating when it is wrong about something too.
