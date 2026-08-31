# Research appendix

This folder is a **working document, not published findings.** It is retained in the
repository unedited because the engineering work in this project is a direct response to
what happened here.

## What this is

Seven research agents were run in parallel over the LA City campaign-contributions domain
(`agent1`–`agent7`), each writing its own notes. `summary.md` is the synthesis pass that
followed, which re-checked their claims against primary sources.

The synthesis pass found that several agent claims were confidently stated and wrong:

- Quotations attributed to named public officials that **do not appear** in the source
  documents they were credited to.
- An enforcement summary that omitted more than a third of the money involved and the
  most prominent name in it.
- A dollar figure attached to the wrong entity.
- An automated re-parse of an election canvass — whose column headers are printed as
  vertical ASCII — that **swapped two races and would have reported losing candidates as
  winners.**

These are recorded in the "Corrections from primary-source retrieval" section of
`summary.md`, with dates and source URLs.

## How to read this folder

- **`summary.md` supersedes the per-agent files.** Where they disagree, the per-agent
  files are the earlier, less reliable version. They are kept so the corrections are
  verifiable rather than merely asserted.
- **Claims marked unverified are unverified.** `summary.md` flags material it could not
  retrieve, sources that were blocked, and figures taken from indexed abstracts rather
  than page-numbered passages. Those flags are load-bearing — do not read past them.
- **The corrections table records research errors, not allegations.** Where it notes that
  a quotation was misattributed to a named individual, the finding is that *the agent
  fabricated the quotation* — not that the person said or did anything. Named individuals
  appear here because they appear in public records, court documents, and published
  reporting, all cited inline.
- **This data covers contributions received only.** Schedules A/B/C/I are money in.
  Expenditure schedules (D/E/F) are a separate dataset and are not present. Any claim
  about spending, advertising, or cost-per-vote in these notes is sourced to outside
  reporting and must never be attributed to this repository's data.

## Why it is kept

The central engineering argument of this project is that fast, uncertified analysis is
legitimate and useful, but must be labelled and must not be allowed to publish. This
folder is the evidence for that argument: maximum parallel throughput, zero governance,
and a verification layer that caught the difference.

See `docs/adr/0004-uncertified-sources.md` for how that conclusion is enforced in the
model rather than merely described here.
