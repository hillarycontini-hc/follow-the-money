# Research Summary — Follow the Money (LA Campaign Contributions)

Synthesis of seven research agents (`agent1-news.md`, `agent2-academic.md`, `agent3-campaigns.md`,
`agent4-outcomes.md`, `agent5-lavote.md`, `agent6-2024.md`, `agent7-lappl.md`) against the CA460
contributions dataset (`data.csv`, 418,748 rows, Oct 2001–Aug 2026, LA City Ethics Commission via
Socrata `m6g2-gc6c`).

Compiled 2026-08-30. **Revised** after primary-source retrieval via browser — see
[Corrections](#corrections-from-primary-source-retrieval), which overturns several quotes the
agents carried from search snippets.

---

## Part 1 — Most Impactful Learnings

### 1. Money did not buy the biggest race in LA history — and the data shows exactly why

Caruso outspent Bass roughly 13-to-1 and lost.

> "How Bass vs. Caruso for L.A. Mayor Became the Most Expensive Race in Los Angeles History"
> — PBS SoCal, https://www.pbssocal.org/news-community/how-bass-vs-caruso-for-l-a-mayor-became-the-most-expensive-race-in-los-angeles-history

Caruso spent $67.6M in the general period vs. Bass's $5.2M, took 85% of all ad spending, and paid
**$338.42 per vote** across primary+general against Bass's $21.94. Outcome:
Bass 509,944 (54.83%) to Caruso 420,030 (45.17%)
(https://en.wikipedia.org/wiki/2022_Los_Angeles_mayoral_election).

**Data check:** Caruso's committee shows $108,288,665 on Schedule A — but $107,258,144 is a single
contributor, `RICK J. CARUSO`, and *the identical $107,258,144 also appears on Schedule B (loans)*.
His "fundraising" is one man lending himself money, booked twice. Bass's 2022 committee raised
$7,210,768 on Schedule A.

### 2. The LAPPL is the single best-documented thread in the entire dataset

**Data check — every LAPPL-linked committee, by cycle (Schedule A receipts):**

| Cycle | Committee | Received |
|---|---|---|
| 2013 | California Law and Order IE Cmte (Support Greuel for Mayor) | $850,000 |
| 2017 | Yes on Charter Amendment C (police discipline) | $327,327 |
| 2022 | Neighbors for a Safer and Cleaner LA **Opposing Karen Bass** | $4,002,000 |
| 2022 | Residents for Safer and Cleaner Neighborhoods **Supporting Traci Park** | $488,600 |
| 2024 | LAPPL Independent Expenditure Committee | $3,295,000 |
| 2024 | LAPPL PAC | $2,127,868 |
| 2024 | …**Opposing Nithya Raman** for City Council 2024 | $550,000 |

**2024 — not 2022 — was their biggest cycle** ($5.97M vs. $4.49M). Agent 7 assembled the sourced
win/loss record: LAPPL's preferred side **won** 2017 (Amendment C passed) and 2022 CD11 (Park won);
**lost** 2013 (Greuel), 2022 Mayor (opposed Bass, Bass won), and 2024 CD4 (opposed Raman, Raman won
outright at 50.67%). Roughly 2-for-5 despite outspending nearly everyone.

**And they switched sides.** Having spent $4M against Bass in 2022, the union backs her in 2026:

> LAPPL was Bass's "foe when she ran for office in 2022, backing her opponent Rick Caruso, but…
> she's running for re-election in 2026 — and this time she has the union's support"
> — AOL/wire, May 1 2026, via `agent7-lappl.md`

Agent 7 found **no outlet reporting the union's own stated rationale** for the reversal — only the
fact of it. That is an open question, not a gap to paper over.

### 3. Independent expenditure money dwarfs candidate money and is built to be hard to trace

> "Those money flows from independent expenditure committees have backed Bass 36-to-1,
> compared to Raman."
> — LAist, Nick Gerda and Maloy Moore, Aug 5 2026,
> https://laist.com/news/politics/bass-campaign-spending-finance-raman-mayor

> "That IE money often flows through multiple committees — many of which combine money meant for
> candidates in multiple different races — on its way to election ads, which can make the money
> hard for the public to easily track."
> — same article

> "State law allows individual donors to spend unlimited amounts on elections through IEs, as
> long as it's not coordinated with the candidates' campaigns."
> — same article

**Data check:** P/G committee types are 2.6% of rows but 39% of dollars, averaging ~$25K per gift
vs. $1,133 for candidate committees. Top P/G receipts: NEA Advocacy Fund ($80.2M), a UTLA-sponsored
educators' PAC ($13.3M), `Controller for Change, Supporting Zach Sokoloff` ($7.83M), `Angelenos
Against Higher Property Taxes – No on ULA` ($7.21M), `Communities United for Bass` ($6.23M).

### 4. Pay-to-play is the moral center, and the federal record is stronger than we thought

**Huizar** — 156 months (13 years), $443,905 restitution to the City, $38,792 to the IRS. He sought
**nearly $2 million** in benefits (not $1.5M as previously recorded).

> "No one is above the law. Today's sentence shows that even a powerful elected official like
> Huizar will be held accountable for engaging in criminal misconduct. Huizar was elected to serve
> the interests of the hard-working people of Los Angeles, but he instead served his own personal
> interests in a long-running, pay-to-play, bribery scheme. Our community deserves better."
> — U.S. Attorney Martin Estrada, DOJ press release 24-017, Jan 26 2024,
> https://www.justice.gov/usao-cdca/pr/former-los-angeles-politician-jose-huizar-sentenced-13-years-federal-prison

> "This years-long investigation uncovered one of the most audacious public corruption cases in
> this city's history."
> — Donald Alway, Assistant Director in Charge, FBI Los Angeles, same release

Judge John F. Walter said public corruption carries "the real potential to destroy the delicate
fabric of our democracy" and causes the public "to disengage in the democratic process" and "give
up all hope of participating" with the government (same release).

The campaign-finance hook is explicit and directly relevant to our data:

> "When Huizar's final term for the CD-14 Council seat was set to expire in 2020, Huizar pushed his
> wife, who had never held public office, to run as his successor, then used the CD-14 Enterprise
> and the pay-to-play scheme to extract campaign contributions that would allow him to maintain
> political power through her."
> — same release

**Ridley-Thomas** — 42 months, $30,000 fine, for routing **$100,000 of his campaign funds** through
USC into his son's nonprofit.

> Judge Fischer said Ridley-Thomas engaged in a "shakedown" and that he used his "[political]
> support as a bargaining chip to get benefits for his son." Judge Fischer also noted, "There is
> simply no justification for monetizing a public office."
> — DOJ press release 23-186, Aug 28 2023,
> https://www.justice.gov/usao-cdca/pr/mark-ridley-thomas-sentenced-3-12-years-prison-corruptly-securing-benefits-son-school

> "By funneling the payment through USC, Ridley-Thomas attempted to disguise the true source of a
> $100,000 payment to make it appear as though USC, not Ridley-Thomas, was the generous benefactor
> supporting his son."
> — same release

### 5. Academic research says money buys access and attention, not votes

> "When informed prospective attendees were political donors, senior policy makers made themselves
> available between three and four times more often. These findings underscore concerns about the
> Supreme Court's recent decisions deregulating campaign finance."
> — Kalla & Broockman, *AJPS* 60(3), 2016,
> https://econpapers.repec.org/RePEc:wly:amposc:v:60:y:2016:i:3:p:545-558

> "Ultimately, we find a robust relationship between donors and speech, indicating a more pervasive
> role of money in politics than previously assumed."
> — Goel et al., *PLOS ONE*, 2023,
> https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0291169

### 6. Local developer money causally changes land-use outcomes

> "Money in politics is the subject of great debate at every level of government, yet it has
> principally been studied at the federal level in the US." … "campaign contributions from organized
> interests appear to play an important role in dictating policy outcomes at the local level."
> — Gaudette & de Benedictis-Kessner, "Local Money," Harvard Kennedy School, 2024,
> https://www.hks.harvard.edu/publications/local-money-evaluating-effects-municipal-campaign-contributions-housing-policy

3M+ municipal contributions across five states; real-estate donations (median $500 vs. $100
otherwise) causally associated with more multifamily permits.

### 7. The 2019 developer ban had a two-year loophole — and our data shows money pouring through it

This is the finding that changed most on primary-source retrieval. LA became the first US city to
ban developer contributions, Dec 4 2019:

> "Today, we took a crucial step in rebuilding trust in City Hall. There is nothing more fundamental
> than building trust in our democracy, and today, we are laying the foundation for a City Hall that
> works for the people."
> — Councilman David Ryu, who spearheaded the legislation, quoted in The Real Deal, Dec 4 2019,
> https://therealdeal.com/la/2019/12/04/la-becomes-1st-city-to-enact-ban-on-developer-money/

**The critical detail, which no agent had:**

> "Before the vote, the Los Angeles Times had reported that the legislation would not take effect
> until after the March 2022 primary elections. The implementation delay would let candidates for
> mayor, controller, city attorney and the majority of the 15 city council seats collect money from
> developers in the next election cycle."
> — same article

> "And even after the bill goes into effect, developers may continue to make unlimited donations to
> independent expenditure committees… Additionally, the legislation does not alter the practice of
> elected officials soliciting donations from developers toward officials' hand-picked charities."
> — same article

> "Government watchdog nonprofits including California Common Cause have criticized the bill for
> letting incumbent council members accumulate developer money in the next election cycle before
> only partly turning the spigot off."
> — same article

**Data check — developer/real-estate-occupation money to candidate committees, Schedule A:**

| Year | Amount | Rows |
|---|---|---|
| 2017 | $228,572 | 486 |
| 2018 | $80,700 | 154 |
| 2019 | $231,344 | 493 |
| 2020 | $184,183 | 464 |
| **2021** | **$545,932** | 950 |
| **2022** | **$625,317** | 1,360 |
| 2023 | $107,367,865 *(Caruso self-loan — exclude)* | 314 |
| 2024 | $127,486 | 253 |
| 2025 | $260,515 | 426 |

2021 and 2022 are the two highest non-Caruso years on record — a 2.4x and 2.8x jump over the
2017–2020 baseline. **The Real Deal explains exactly why: the ban did not bind until after the
March 2022 primary.** What looked like an anomaly is a documented loophole being used, and the
2024 collapse to $127,486 is consistent with the ban finally taking effect. This is now the
best-supported original finding available — reporting and filings independently converge.

*Note: the 2019 vote was reported via CBSLA; The Real Deal is aggregating LAT and CBSLA. Worth
retrieving the underlying LA Times piece before publication.*

### 8. Enforcement is real but small — and one name in it is a surprise

Verified from the Ethics Commission's own releases (both previously unreachable):

**Koretz, $2,500, Feb 15 2023** — his 2022 Controller campaign asked Jill Banks Barad-Hopkins, a
sitting Board of Water and Power Commissioner, to host a fundraiser; city commissioners are barred
from fundraising for city candidates. The campaign returned the contributions once alerted.

> "Today's decision demonstrates that the Ethics Commission is committed to upholding the laws that
> protect the integrity of the electoral process and help to foster public confidence in local
> government."
> — Jeffery Daar, President of the Ethics Commission,
> https://ethics.lacity.gov/news/ethics-commission-fines-former-councilmember/

**$70,000 across six cases, Apr 17 2024** — and the largest single fine went to **Leslie Moonves,
former CEO of CBS**, fined the maximum $15,000 for aiding the disclosure and misuse of confidential
City information about a police complaint, and for inducing a former police captain to misuse his
position. Also: AIDS Healthcare Foundation $10,000 and its policy director Susie Shannon $12,500;
Western States Regional Council of Carpenters $7,500 and former political director Derek Mazzeo
$12,500 (Mazzeo also "made prohibited political contributions"); Richard Jacobs / RDJ Advisors
$12,500.

> "Those who are complicit in the misuse of confidential information or the misuse of a City
> position will be held accountable. Those who fail to inform the public of their lobbying efforts
> will also be held accountable."
> — Jeffery Daar, https://ethics.lacity.gov/news/ethics-commission-imposes-fines-totaling-70000/

Agent 1's snippet-derived version of this release named only WSRCC, Mazzeo, and Jacobs — it missed
Moonves and AHF entirely, i.e. more than a third of the money and by far the most newsworthy name.

---

## Part 2 — Official Election Outcomes Now In Hand

Agent 5 pulled certified results from lavote.gov; I closed its remaining gap by retrieving the LA
City Clerk's official canvass for the May 16 2017 runoff
(https://cityclerk.lacity.org/election/archives/archives2017/general/stvctotl.txt).

### 2024 cycle — official (lavote.gov IDs 4316 primary, 4324 general)

| Race | Winner | Result |
|---|---|---|
| CD14 | **Ysabel Jurado** | Gen: 46,007 (57.17%) def. Kevin de León 34,472 (42.83%) |
| CD10 | **Heather Hutt** | Gen: 50,895 (62.81%) def. Grace Yoo 30,133 (37.19%) |
| CD2 | **Adrin Nazarian** | Gen: 44,538 (53.84%) def. Jillian Burgos 38,185 (46.16%) |
| CD12 | **John Lee** | Primary outright: 33,574 (62.30%) def. Serena Oberstein 20,314 |
| CD4 | **Nithya Raman** | Primary outright: 32,562 (50.67%) def. Ethan Weaver 24,799 |
| CD8 | **Marqueece Harris-Dawson** | Primary outright: 19,569 (78.41%) |
| CD6 | **Imelda Padilla** | Primary outright: 16,476 (78.35%) |
| LAUSD D7 | **Tanya Ortiz Franklin** | Primary outright: 34,380 (55.91%) |

Winners known but exact general-round totals **not** confirmed from an official page: LAUSD D3
(Schmerelson over Chang), D5 (Griego over Ortiz), D1 (Newbill over Al-Alim). lavote.gov's general
page returned no LAUSD entries.

Note: Raman won outright at 50.67% *despite* the $550,000 LAPPL committee against her — and Agent 6
found the total anti-Raman IE effort exceeded $1M, funded by Douglas Emmett ($400K) and LAPPL
($164K direct).

> "we do not discuss the specific reasons for our contributions"
> — Douglas Emmett, declining to explain its anti-Raman spending, via `agent6-2024.md`

### 2017 cycle — official (lavote.gov ID 3577 primary; City Clerk canvass for the May 16 runoff)

| Race | Winner | Result |
|---|---|---|
| Mayor | **Eric Garcetti** | Primary outright: 331,310 (81.37%) |
| City Attorney | **Mike Feuer** | Unopposed, 306,867 |
| Controller | **Ron Galperin** | Unopposed, 291,321 |
| CD1 | **Gil Cedillo** | Runoff: 11,415 (71.63%) def. Joe Bray-Ali 4,521 (28.37%) |
| CD7 | **Monica Rodriguez** | Runoff: 9,588 (53.64%) def. Karo Torossian 8,287 (46.36%) |
| CD5 | **Paul Koretz** | Primary outright: 25,914 (65.88%) |
| LAUSD D4 | **Nick Melvoin** | Runoff: 38,673 (57.23%) def. Steve Zimmer 28,897 (42.77%) |
| LAUSD D6 | **Kelly Gonez** | Runoff: 16,961 (51.46%) def. Imelda Padilla 15,996 (48.54%) |
| **Charter Amendment C** | **PASSED** | YES 113,198 (54.82%) — NO 93,296 (45.18%) |

Turnout for the May 2017 runoff was **10.71%** citywide (216,790 of 2,024,106 registered). Amendment
C — the measure LAPPL put $327,327 behind — passed on that turnout. CD1 2017 is also the race
Cedillo won by 43 points; he lost the same seat outright in the 2022 primary to Eunisses Hernandez.

⚠️ **Parsing warning for anyone reusing this file.** The City Clerk canvass prints candidate names
as *vertical ASCII* down the column headers. An automated read of it swapped CD7 and LAUSD D6,
which would have reported Torossian and Padilla as winners. Every figure in the 2017 table above
was read column-by-column from the raw text and cross-checked against known outcomes. Do not
re-extract that file with an LLM without verifying alignment.

---

## Part 3 — How Well Does the Research Align With Our Data?

### Verdict

**Strong on money-in, absent on money-out, and outcomes are now largely solved.** The outcome gap
that blocked every comparative question is closed for 2017, 2020, 2022 and 2024. What remains
genuinely missing is expenditures and endorsements-at-scale.

### Where research and data corroborate each other

| Research finding | Our data | Alignment |
|---|---|---|
| LAPPL spent $4M+ against Bass (ABC7) | `Neighbors for a Safer and Cleaner LA…LAPPL` = $4,002,000 | **Near-exact** |
| Bass raised $3.7M+ for 2026, Raman $1.1M+ (NBC LA) | Bass $3,747,646; Raman $1,110,229 | **Near-exact** |
| Caruso self-financed almost all of it (PBS SoCal) | $107.26M of $108.29M from `RICK J. CARUSO` | **Confirmed** |
| IE money dwarfs candidate money (LAist) | P/G: 2.6% of rows, 39% of dollars | **Confirmed** |
| Developer ban delayed to after March 2022 (TRD) | 2021–22 are peak non-Caruso developer years | **Confirmed — strongest original finding** |
| Anti-Raman IE >$1M, Douglas Emmett $400K (Agent 6) | LAPPL anti-Raman cmte $550,000 | **Partial — IE totals exceed our receipts** |

### Where our data still cannot answer the question

1. **Contributions, not expenditures.** Schedules A/B/C/I are money *received*. Caruso's $67.6M
   spent, $23.9M on ads, 85% ad share, $338.42/vote are **expenditure** figures (Schedules D/E/F)
   absent from this file. Any cost-per-vote claim must cite PBS SoCal, never our data.
2. **No endorsement data.** Still only what Agents 4, 6 and 7 sourced by hand. Best coverage:
   LAPPL→Caruso/Park, DSA-LA→Soto-Martínez/Raman, UTLA→Schmerelson ($2.4M, per Agent 6),
   CCSA→Chang, LA Times editorial board→Mejia/Hernandez/Yaroslavsky/McOsker/Santiago.
3. **No public matching funds as such.** Not a labeled contribution type. Schedule I "Misc. Increase
   to Cash" is the nearest candidate but is a documented grab-bag — attributing it to matching funds
   would be an assumption. Needs Ethics Commission matching-funds disclosures.
4. **No IE targeting field.** LAist's 36-to-1 requires knowing which candidate each IE
   supported/opposed. Derivable from `Committee Name` string-parsing, since LA committee names are
   literal ("…Opposing Karen Bass…"), but flag it as derived, not native.
5. **IE receipts ≠ IE spending.** Agent 6 puts the anti-Raman effort above $1M; our filings show
   $550K received by the LAPPL committee. Different committees, different measures. Don't conflate.

### Corrections from primary-source retrieval

Retrieving the blocked pages overturned material the agents carried on snippet confidence. This is
the strongest argument for verifying before publishing anything:

| Claim previously recorded | Reality |
|---|---|
| Estrada: "one of the most wide-ranging and brazen public corruption cases uncovered in this district" | **Not in the release.** Estrada said "No one is above the law…" |
| Alway: "Mr. Huizar's actions, to include accepting a staggering amount of bribe money and lavish gifts, eroded the trust in the office…" | **Not in the release.** Alway said "…one of the most audacious public corruption cases in this city's history." |
| Huizar sought ~$1.5M in bribes | DOJ says **nearly $2 million** in benefits sought; $1.5M was the fine on 940 Hill LLC |
| $70,000 fines = WSRCC + Mazzeo + Jacobs | **Six cases**, and the top fine was **Leslie Moonves, $15,000** — omitted entirely |
| LA Times "job half-finished" editorial | Still unverified; PressReader remains unretrieved |
| LAUSD D6 2017: uncertain | **Official:** Gonez 16,961 def. Padilla 15,996 — agent's secondary figure was right, an automated re-parse was wrong |

### Reliability caveats still outstanding

- **Agent 2** produced **5** verified findings, not 8 — it correctly dropped unread papers rather
  than fabricate citations. Sprick Schuster's *JOP* spending/vote-share study, the most relevant
  paper, could not be opened. **No USC Price, UCLA Luskin, or Berkeley IGS study on LA campaign
  finance was found at all.**
- The Malbin & Parrott matching-funds quote is from an indexed abstract, not a page-numbered
  passage. Verify against the PDF before publishing.
- **All 2026 races remain unresolved.** Primary was set for June 2 2026, runoff Nov 3 2026. No
  agent asserted an outcome and neither should we.
- Agent 5 hit its 12-search cap; LAUSD 2024 general totals and 2026 results were never attempted.

### Still blocked (need site permission or manual retrieval)

Chrome retrieved the four high-priority pages plus The Real Deal. These remain:

- `dsa-la.org` — DSA-LA endorsement pages (blocked at extension permission level, not by the site;
  grantable)
- `lapublicpress.org` — five articles across Agents 6 and 7, incl. "**$1.4 million to replace
  Councilmember Nithya Raman didn't work**" and two CD14 candidate guides (403)
- `nbclosangeles.com` CD14 candidate guide (403)
- `the74million.org` LAUSD board race piece (403)
- `pressreader.com` LA Times 2017 editorial (403)
- `kcrw.com` 2013 outside-spending piece (429)

The LA Public Press Raman piece is the highest value of these — it goes directly to the
does-money-win question on a race we now have official results for.

### The three stories the combined material supports

1. **"LA banned developer money in 2019 — and then gave everyone two more years to collect it."**
   Now the strongest option. Ryu's on-record promise, Common Cause's contemporaneous objection, the
   documented delay to after the March 2022 primary, and our own filings showing 2021–22 as peak
   developer years, collapsing after. Reporting and data converge independently. Depends on
   normalizing `Contrib Employer` (60k+ free-text variants).
2. **"One police union, six committees, thirteen years, and a 2-for-5 record."** Fully mapped in the
   filings, outcomes now official for every race, and it ends on an unexplained reversal — $4M
   against Bass in 2022, backing her in 2026, with no reported rationale.
3. **"The most expensive race in LA history was won by the candidate who spent 13x less."** Fully
   sourced and data-corroborated, but the least original — it has been written many times.

### Biggest remaining need

Not outcomes anymore — those are largely solved. It is **expenditure data (Schedules D/E/F)**. Every
"what did the money buy" question needs it, and it is a separate Socrata dataset from the same
publisher. Worth checking whether `data.lacity.org` publishes it before commissioning more research.
