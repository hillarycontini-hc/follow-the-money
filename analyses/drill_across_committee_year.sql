-- Drill-across: one question answered from two fact tables that never touch each other.
--
--     dbt compile --select drill_across_committee_year
--
-- The point of conforming a dimension is that two facts at different grains can be
-- reported side by side without either one distorting the other. This query is the
-- proof, and it is deliberately written the long way.
--
-- fct_contribution is a transaction fact: one row per disclosed contribution line.
-- fct_loan_snapshot is a periodic snapshot: one row per loan balance re-declared on a
-- filing period, mostly $0.00 carry-forwards. They share no grain, no row count, and no
-- meaningful join key at the row level.
--
-- So they are never joined at the row level. Each fact is aggregated on its own to the
-- common grain first -- committee version x calendar year -- and only those two
-- summaries are joined. Joining the facts directly would fan out every contribution by
-- every loan period the committee filed, and the total would be nonsense in a way that
-- still returns rows.
--
-- Two things make the common grain possible, and both are properties of the model
-- rather than of this query:
--
--   1. dim_committee is conformed AND Type 2. Both facts carry the same committee_key,
--      which is a hash of (committee_id, committee_name) -- so a contribution and a
--      loan line up only when they belong to the same committee *identity version*.
--      Under a Type 1 dimension this query would still run and would silently report
--      2013 money against a 2024 committee name.
--
--   2. dim_date is conformed and role-played. fct_contribution joins it as the
--      contribution date; fct_loan_snapshot joins it as the *period end* date. Two
--      different roles, one dimension, one definition of "2023" -- which is the only
--      reason the two sides of the full outer join mean the same thing by a year.
--
-- What it shows: in 2022 the Caruso committees carry ~$105M of loan balance and almost
-- no contributions. In 2023 the same dollars reappear, to the cent, as contributions --
-- flagged is_self_loan_mirror. That is the $107M double-disclosure behind the 489x gap
-- in the README, visible here as a mechanism rather than as an assertion.

with contribution_by_committee_year as (

    -- Aggregate fact 1 to the conformed grain, alone.
    select
        f.committee_key,
        d.calendar_year,

        sum(f.amount)                                       as contributed_amount,
        count(*)                                            as contribution_lines,
        count(distinct f.contributor_name)                  as contributor_names,

        -- Certified money metrics exclude these; carried here so the drill-across can
        -- show the mirror rather than quietly net it out.
        sum(case when f.is_self_loan_mirror then f.amount else 0 end)
                                                            as mirrored_amount

    from {{ ref('fct_contribution') }} f
    join {{ ref('dim_date') }} d
        on f.contribution_date_key = d.date_key
    group by 1, 2

),

loan_by_committee_year as (

    -- Aggregate fact 2 to the same conformed grain, alone -- via a different date role.
    select
        f.committee_key,
        d.calendar_year,

        -- Dollars are safe to sum. Rows are not: a row is a filing period, not a loan,
        -- and 2,762 of the 3,678 rows in this fact are $0.00 carry-forwards. So "how
        -- many loans" is a distinct count of lenders, never a count of rows.
        sum(f.outstanding_balance)                          as loan_balance,
        count(distinct f.lender_name)                       as distinct_lenders,
        count(*)                                            as snapshot_rows,
        sum(case when f.is_carry_forward then 1 else 0 end) as carry_forward_rows

    from {{ ref('fct_loan_snapshot') }} f
    join {{ ref('dim_date') }} d
        on f.period_end_date_key = d.date_key
    group by 1, 2

),

drilled as (

    -- Full outer join, because a committee-year may exist in either fact or both. An
    -- inner join here would silently drop every committee that took a loan and reported
    -- no contributions that year, which is most of them.
    select
        coalesce(c.committee_key,   l.committee_key)   as committee_key,
        coalesce(c.calendar_year,   l.calendar_year)   as calendar_year,

        coalesce(c.contributed_amount, 0)              as contributed_amount,
        coalesce(c.mirrored_amount,    0)              as mirrored_amount,
        coalesce(c.contribution_lines, 0)              as contribution_lines,
        coalesce(c.contributor_names,  0)              as contributor_names,

        coalesce(l.loan_balance,       0)              as loan_balance,
        coalesce(l.distinct_lenders,   0)              as distinct_lenders,
        coalesce(l.snapshot_rows,      0)              as snapshot_rows,
        coalesce(l.carry_forward_rows, 0)              as carry_forward_rows,

        c.committee_key is not null                    as appears_in_contributions,
        l.committee_key is not null                    as appears_in_loans

    from contribution_by_committee_year c
    full outer join loan_by_committee_year l
        on  c.committee_key  = l.committee_key
        and c.calendar_year  = l.calendar_year

)

select
    -- Dimension attributes are resolved once, at the end, from the conformed dimensions
    -- rather than carried through either aggregate.
    cm.committee_name,
    cm.committee_id,
    cm.version_number,
    cm.candidate_name,
    cm.office,
    cm.committee_type_name,

    dd.calendar_year,
    dd.is_city_election_year,

    round(dr.contributed_amount, 2)                    as contributed_amount,
    round(dr.mirrored_amount, 2)                       as mirrored_amount,

    -- What a governed contribution total actually reports for this committee-year.
    round(dr.contributed_amount - dr.mirrored_amount, 2)
                                                       as contributed_less_mirrors,

    round(dr.loan_balance, 2)                          as loan_balance,
    dr.distinct_lenders,
    dr.contribution_lines,
    dr.snapshot_rows,
    dr.carry_forward_rows,

    case
        when dr.appears_in_contributions and dr.appears_in_loans then 'both facts'
        when dr.appears_in_contributions                         then 'contributions only'
        else                                                          'loans only'
    end                                                as coverage

from drilled dr

join {{ ref('dim_committee') }} cm
    on dr.committee_key = cm.committee_key

-- dim_date is grouped to the year here, so it is joined on the year rather than a day.
-- Distinct because the spine has one row per day.
join (
    select distinct calendar_year, is_city_election_year
    from {{ ref('dim_date') }}
) dd
    on dr.calendar_year = dd.calendar_year

-- No filter. The full outer join above is the whole point, and a WHERE that required
-- both sides would quietly turn it back into an inner join -- dropping, among others,
-- the 2023 committee-year where $40.7M of mirrored contribution lands in a year with no
-- loan snapshot at all. Filter on `coverage` downstream if you want one side only.

order by
    greatest(dr.loan_balance, dr.mirrored_amount) desc,
    dr.contributed_amount desc
