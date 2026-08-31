{{ config(materialized='table') }}

{#
    GRAIN: one row per loan balance as re-declared on a filing period -- a periodic
    snapshot, not a transaction fact.

    This is the distinction that makes Schedule B dangerous. 9,750 of its 10,748 rows
    carry an amount of $0.00: they are carry-forwards re-stating an outstanding loan in
    every subsequent period until it is repaid. One Krisiloff loan appears across 19
    filing periods; one O'Farrell loan across 17, still running into 2026.

    So the dollar total is safe to sum but the row count is not: counting rows here
    counts filing periods, not loans. Anyone asking "how many loans were made?" must
    count distinct lender/committee pairs, not rows.
#}

select
    contribution_key                                    as loan_snapshot_key,

    {{ committee_key('committee_id', 'committee_name') }}
        as committee_key,
    period_end_date                                     as period_end_date_key,

    contributor_name                                    as lender_name,
    contributor_occupation                              as lender_occupation,
    contributor_employer                                as lender_employer,

    contribution_date,
    period_begin_date,
    period_end_date,

    amount                                              as outstanding_balance,
    amount_paid_or_forgiven,

    -- A zero balance on Schedule B is a carry-forward, not a loan of nothing.
    amount = 0                                          as is_carry_forward

from {{ ref('stg_contributions') }}
where schedule_code = 'B'
  and is_itemized
  and has_plausible_date
