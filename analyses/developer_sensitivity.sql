-- Sensitivity of the developer-money finding to how "developer" is defined.
--
-- The claim this project makes is that Los Angeles banned developer contributions in
-- December 2019, but wrote the ordinance so it did not bind until after the March 2022
-- primary -- and that the filings show money moving through the gap.
--
-- That claim has two halves, and they are not equally sound. This query is here to say
-- so out loud, under four definitions of "developer" spanning a wide range of breadth:
--
--   * The 2021-22 spike holds under every definition. 2021 runs 2.82x to 3.01x of
--     baseline and 2022 runs 3.55x to 4.10x, whichever way "developer" is drawn. It is
--     not an artefact of the classifier.
--
--   * The post-ban collapse does not hold. It does not merely weaken -- it changes
--     direction. Under the narrow definition 2024 falls to 0.69x of baseline, which
--     reads as the ban taking effect. Under the standard and broad definitions the same
--     year sits at 1.55x and 1.56x: above baseline, which reads as no effect at all.
--     The narrow definition covers only occupations that say "developer" in those
--     words, and what it is really measuring in 2024 is that a handful of people
--     stopped writing that job title -- not that the money stopped.
--
-- Publication rule that follows from this table: ship the spike as a finding, ship the
-- collapse as "consistent with, but not established by, this data."
--
-- Every column here excludes self-loan mirrors. Without that exclusion 2023 reads
-- $107,478,000 instead of $219,851 -- a factor of 489 -- because the largest
-- self-described real-estate developer in the file is a candidate lending his own
-- campaign money.

with classified as (

    select
        extract(year from contribution_date)::int as contribution_year,
        amount,
        upper(trim(coalesce(contributor_occupation, ''))) as occupation
    from {{ ref('fct_contribution') }}
    where not is_self_loan_mirror
      and schedule_code = 'A'

),

by_year as (

    select
        contribution_year,
        sum(case when {{ is_developer_narrow('occupation') }}
                 then amount else 0 end) as narrow,
        sum(case when {{ is_developer_standard('occupation') }}
                 then amount else 0 end) as standard,
        sum(case when {{ is_developer_broad('occupation') }}
                 then amount else 0 end) as broad,
        sum(case when {{ is_developer_broadest('occupation') }}
                 then amount else 0 end) as broadest
    from classified
    group by contribution_year

),

-- Baseline is the four years before the ordinance was adopted, so the comparison is
-- against a settled period rather than against a single cherry-picked year.
baseline as (

    select
        avg(narrow)   as narrow,
        avg(standard) as standard,
        avg(broad)    as broad,
        avg(broadest) as broadest
    from by_year
    where contribution_year between 2016 and 2019

)

select
    y.contribution_year,

    y.narrow,
    y.standard,
    y.broad,
    y.broadest,

    round(y.narrow   / nullif(b.narrow,   0), 2) as narrow_vs_baseline,
    round(y.standard / nullif(b.standard, 0), 2) as standard_vs_baseline,
    round(y.broad    / nullif(b.broad,    0), 2) as broad_vs_baseline,
    round(y.broadest / nullif(b.broadest, 0), 2) as broadest_vs_baseline

from by_year y
cross join baseline b
where y.contribution_year between 2016 and 2025
order by y.contribution_year
