-- The audit ladder: how a naive total becomes a defensible one, one exclusion at a time.
--
-- This query is the argument for the whole project. Every step removes money that a
-- reasonable person would have summed, and each removal is defensible in a sentence.
-- Run it with:
--
--     dbt compile --select naive_vs_governed
--
-- and execute the compiled SQL, or paste it into a DuckDB session against
-- followthemoney.duckdb.
--
-- Note that step 4 removes more than steps 2 and 3 combined. The exclusion nobody
-- thinks of is larger than the two everybody argues about.

with all_disclosed as (

    select
        schedule_code,
        is_itemized,
        amount
    from {{ ref('stg_contributions') }}
    where has_plausible_date

),

mirrored as (

    select sum(f.amount) as mirror_total
    from {{ ref('fct_contribution') }} f
    where f.is_self_loan_mirror

),

ladder as (

    select 1 as step,
           'Naive: sum every amount in the file' as description,
           sum(amount) as running_total
    from all_disclosed

    union all
    select 2,
           'Less Schedule B: loans are borrowed money, not gifts',
           sum(case when schedule_code != 'B' then amount else 0 end)
    from all_disclosed

    union all
    select 3,
           'Less Schedule I: 91.8% is public matching funds, i.e. taxpayer money',
           sum(case when schedule_code not in ('B', 'I') then amount else 0 end)
    from all_disclosed

    union all
    select 4,
           'Less unitemized aggregates: period summaries, not contributions',
           sum(case when schedule_code not in ('B', 'I') and is_itemized
                    then amount else 0 end)
    from all_disclosed

    union all
    select 5,
           'Less self-loan mirrors: the same money disclosed twice',
           (select sum(case when schedule_code not in ('B', 'I') and is_itemized
                            then amount else 0 end) from all_disclosed)
           - (select mirror_total from mirrored)

)

select
    step,
    description,
    running_total,
    running_total - lag(running_total) over (order by step) as removed_at_this_step
from ladder
order by step
