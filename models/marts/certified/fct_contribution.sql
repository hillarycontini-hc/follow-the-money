{{ config(materialized='table') }}

{#
    GRAIN: one row per itemised monetary or in-kind contribution line, exactly as
    disclosed on a CA460 filing.

    What that grain deliberately excludes, and why:

      * Schedule B (loans received). Borrowed money is not a contribution. Including it
        adds $127.3M of debt to a total labelled "contributions".
      * Schedule I (miscellaneous increases to cash). 91.8% of it is public matching
        funds paid by the City of Los Angeles -- taxpayer money, not donations.
      * Unitemized rows. These are period aggregates of sub-threshold giving: 7,064
        rows on Schedule A holding $174,806,068, with no contributor attached. They are
        excluded here because they are a different grain, NOT because they duplicate
        anything -- they are real, additional money. See fct_unitemized_aggregate, and
        note that the certified contributions_total metric adds them back. Any total
        built from this fact alone understates receipts by $174.8M.
      * Quarantined rows. 32 rows whose date cannot be trusted.

    There is no natural key. Grouping on all 30 source columns still leaves 1,395
    duplicate rows worth $17,802,401, and they are not all errors -- same-day
    instalments and the "and Affiliated Entities" disclosure convention both produce
    legitimate twins. They are preserved, distinguished by occurrence index, and
    flagged; deleting them would silently remove $17.8M of real filings.
#}

with contributions as (

    select *
    from {{ ref('stg_contributions') }}
    where schedule_code in ('A', 'C')
      and is_itemized
      and has_plausible_date

),

mirrors as (

    select committee_id, contributor_name
    from {{ ref('int_self_loan_mirrors') }}

),

duplicate_groups as (

    select
        split_part(contribution_key, ':', 1) as content_hash,
        count(*)                             as occurrences
    from contributions
    group by 1

)

select
    c.contribution_key,

    -- Foreign keys -----------------------------------------------------------------
    {{ committee_key('c.committee_id', 'c.committee_name') }}
        as committee_key,
    c.contribution_date                                     as contribution_date_key,

    -- Degenerate dimensions --------------------------------------------------------
    c.schedule_code,
    c.schedule_name,
    c.contribution_type,
    c.contribution_description,

    -- Contributor attributes -------------------------------------------------------
    c.contributor_name,
    c.contributor_city,
    c.contributor_state,
    c.contributor_zip,
    c.contributor_occupation,
    c.contributor_employer,

    -- The certified developer definition. Three wider and narrower variants exist as
    -- macros and are exercised in analyses/developer_sensitivity.sql; only this one is
    -- blessed, and changing it means changing a pinned test.
    {{ is_developer_standard('upper(trim(coalesce(c.contributor_occupation, '')))') }}
        as is_developer_contribution,
    c.intermediary_name,

    -- Dates ------------------------------------------------------------------------
    c.contribution_date,
    c.period_begin_date,
    c.period_end_date,

    -- Measures ---------------------------------------------------------------------
    c.amount,

    -- Flags ------------------------------------------------------------------------
    c.amount < 0                                            as is_refund,
    c.amount = 0                                            as is_zero_amount,
    d.occurrences > 1                                       as is_duplicated_disclosure,

    -- True when this contributor's giving to this committee is mirrored exactly by a
    -- loan on Schedule B. Certified money metrics exclude these rows; see
    -- int_self_loan_mirrors for why the test is exact equality.
    m.committee_id is not null                              as is_self_loan_mirror

from contributions c
left join mirrors m
    on  c.committee_id    = m.committee_id
    and c.contributor_name = m.contributor_name
left join duplicate_groups d
    on split_part(c.contribution_key, ':', 1) = d.content_hash
