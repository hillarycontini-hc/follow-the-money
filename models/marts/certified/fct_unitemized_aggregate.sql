{{ config(materialized='table') }}

{#
    GRAIN: one row per period-aggregate disclosure -- the summary line a committee files
    in place of naming small donors individually.

    These are kept apart from fct_contribution because they are a different grain, not
    because they are duplicates. There are 7,064 such rows on Schedule A alone, holding
    $174,806,068, with no contributor attached to any of it.

    It is tempting to assume these lines summarise the itemised rows beside them, and to
    drop them to avoid double-counting. That assumption is wrong, and measuring it is
    what settled the question. Across the 6,963 committee-periods that carry one, the
    median unitemized line is 1.5% of the itemised total for the same committee and
    period -- and the largest lines of all belong to a committee reporting $0.00
    itemised in those periods, including a single $16,133,477 aggregate.

    They are contributions below the itemisation threshold: real money, disclosed in
    bulk because no individual gift was large enough to require naming a donor. So:

      * They cannot enter donor-level analysis. There is no donor.
      * They MUST be included in any total of money received. Leaving them out
        understates contributions by $174.8M.
#}

select
    contribution_key                                    as unitemized_key,

    {{ committee_key('committee_id', 'committee_name') }}
        as committee_key,
    period_end_date                                     as period_end_date_key,

    schedule_code,
    schedule_name,
    contribution_type,
    contribution_date,
    period_begin_date,
    period_end_date,
    amount

from {{ ref('stg_contributions') }}
where not is_itemized
  and has_plausible_date
