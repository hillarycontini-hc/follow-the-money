{{ config(materialized='view') }}

{#
    Rows that arrived but cannot be trusted to carry a date.

    This model exists so that "how much did we throw away, and why?" has an answer that
    is a query rather than a guess. Downstream facts exclude these rows; a test asserts
    the population stays at its known size, so a sudden increase upstream surfaces as a
    build failure instead of a quietly shrinking total.

    Known population at time of writing: 32 rows.
      * 24 with no contribution date at all
      *  8 with dates outside any plausible range, including 0121-03-08 and 1409-08-01
#}

select
    contribution_key,
    contribution_date_raw,
    contribution_date,
    schedule_code,
    contributor_name,
    committee_name,
    amount,

    case
        when contribution_date is null and nullif(trim(contribution_date_raw), '') is null
            then 'missing_date'
        when contribution_date is null
            then 'unparseable_date'
        else 'implausible_date'
    end as quarantine_reason

from {{ ref('stg_contributions') }}
where not coalesce(has_plausible_date, false)
