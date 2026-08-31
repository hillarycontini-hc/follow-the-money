{{ config(materialized='view') }}

{#
    UNCERTIFIED. Do not build a published number on this model.

    Los Angeles committee names are unusually literal -- "Neighbors for a Safer and
    Cleaner LA, Opposing Karen Bass", "Residents for Safer and Cleaner Neighborhoods,
    Supporting Traci Park" -- so the candidate an independent expenditure committee is
    for or against can often simply be read off the name. That is genuinely useful, and
    it is why this model exists rather than being deleted.

    It is also why this model is not certified. The coverage is not merely incomplete,
    it is biased in the direction that matters most:

      * It resolves a target for 101 of 210 independent-expenditure committees.
      * Those 101 committees hold $54.4M of $289.1M in IE dollars -- 18.8%.

    The gap is not random. The largest IE committees are the ones with anodyne names:
    NEA Advocacy Fund alone holds $80.2M and names no target at all. So any share
    computed from this model systematically understates exactly the committees whose
    money matters most, and would be wrong in a direction a reader could not guess.

    Certifying it would give a regex the authority of a filing. It stays here, in the
    fast lane, labelled -- and dbt enforces that nothing certified may reference it.
#}

with committees as (

    select distinct
        committee_key,
        committee_id,
        committee_name,
        is_independent_expenditure_type
    from {{ ref('dim_committee') }}
    where is_independent_expenditure_type

),

parsed as (

    select
        *,

        case
            when regexp_matches(lower(committee_name), 'oppos(e|ing|ition)') then 'oppose'
            when regexp_matches(lower(committee_name), 'support(s|ing)?')    then 'support'
            when regexp_matches(lower(committee_name), '\bfor\b')            then 'support'
            when regexp_matches(lower(committee_name), '\bagainst\b')        then 'oppose'
            when regexp_matches(lower(committee_name), '\bno on\b')          then 'oppose'
            when regexp_matches(lower(committee_name), '\byes on\b')         then 'support'
        end as inferred_stance,

        -- Everything after the stance word, which is where the target name sits when
        -- there is one. Crude on purpose: a more elaborate parser would not raise
        -- coverage, it would only make the failures harder to notice.
        nullif(trim(regexp_extract(
            committee_name,
            '(?i)(?:opposing|supporting|against|no on|yes on)\s+(.+)$',
            1
        )), '') as inferred_target

    from committees

)

select
    committee_key,
    committee_id,
    committee_name,
    inferred_stance,
    inferred_target,
    inferred_target is not null as has_resolved_target,

    -- Carried explicitly so that anyone reading a result from this model sees the tier
    -- alongside the number, not in documentation they may never open.
    'derived' as source_tier

from parsed
