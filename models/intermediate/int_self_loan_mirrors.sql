{{ config(materialized='view') }}

{#
    Committee/contributor pairs whose Schedule A total is mirrored exactly by their
    Schedule B total -- the same money disclosed twice, once as a contribution and once
    as the loan it actually is.

    Rick Caruso's 2022 mayoral committee reports $108,288,665 on Schedule A, of which
    $107,258,144 is a single contributor named RICK J CARUSO. The identical
    $107,258,144 also appears on Schedule B. Counting both makes him appear to have
    given $214,516,989, and makes any "largest contributor" or "best funded committee"
    answer wrong by more than $100M.

    Two design decisions are load-bearing:

    1. Detection is at the aggregate, not the row. The obvious row-level join on
       committee + contributor + date + amount finds 4 pairs worth $2,000 and misses
       Caruso entirely, because the loan is disclosed on a different schedule with a
       different instalment pattern than the contributions it mirrors.

    2. The threshold is exact equality, not a tolerance -- and not because the data is
       conveniently separated. It is not. Of 149 contributor/committee pairs that both
       gave and lent, 21 sit at exactly 1.0000, and the nearest neighbours are 0.996401
       below and 1.000309 above. The distribution is continuous right up to the
       boundary.

       Exactness is the rule precisely because there is no gap. Equality means the same
       money disclosed twice. Approximate equality means two different sums that happen
       to be close -- a real gift and a real loan from the same person, which is
       ordinary treasurer behaviour. A ±1% tolerance would erase Warren T. Furutani's
       genuine $17,600.61 contribution from every total in this project.
#}

with by_schedule as (

    select
        committee_id,
        contributor_name,
        sum(case when schedule_code = 'A' then amount else 0 end) as schedule_a_total,
        sum(case when schedule_code = 'B' then amount else 0 end) as schedule_b_total
    from {{ ref('stg_contributions') }}
    where committee_id is not null
      and contributor_name is not null
      and is_itemized
      and has_plausible_date
    group by committee_id, contributor_name

),

scored as (

    select
        committee_id,
        contributor_name,
        schedule_a_total,
        schedule_b_total,
        case
            when schedule_a_total > 0
                then schedule_b_total / schedule_a_total
        end as mirror_ratio
    from by_schedule
    where schedule_a_total > 0
      and schedule_b_total > 0

)

select
    committee_id,
    contributor_name,
    schedule_a_total,
    schedule_b_total,
    mirror_ratio
from scored
where mirror_ratio = 1.0
