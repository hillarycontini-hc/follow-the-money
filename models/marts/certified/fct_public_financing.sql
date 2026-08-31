{{ config(materialized='table') }}

{#
    GRAIN: one row per miscellaneous cash increase disclosed on Schedule I.

    Schedule I has been described in this project's own research notes as an
    undifferentiated grab-bag whose contents could not be attributed. That was wrong,
    and this model exists to correct it: 91.8% of Schedule I -- $50,093,747 of
    $54,569,469 -- is public matching funds, explicitly labelled as such in the
    description field and paid by the City of Los Angeles, the LA City Ethics
    Commission, or the LA City Treasury.

    It is therefore taxpayer money flowing to candidates, which is a materially
    different thing from a donation and must never be summed into "contributions".
#}

with schedule_i as (

    select *
    from {{ ref('stg_contributions') }}
    where schedule_code = 'I'
      and is_itemized
      and has_plausible_date

)

select
    contribution_key                                    as public_financing_key,

    {{ committee_key('committee_id', 'committee_name') }}
        as committee_key,
    contribution_date                                   as received_date_key,

    contributor_name                                    as payer_name,
    contribution_description,
    contribution_date,
    period_begin_date,
    period_end_date,
    amount,

    -- Matching funds are identified from the payer and the description together;
    -- neither alone is sufficient, because the city also appears as a payer for
    -- non-matching reimbursements.
    (
        upper(coalesce(contributor_name, '')) in (
            'CITY OF LOS ANGELES',
            'LA CITY ETHICS COMMISSION',
            'LA CITY TREASURY'
        )
        or lower(coalesce(contribution_description, '')) like '%matching%'
        or lower(coalesce(contribution_description, '')) like '%public financing%'
    )                                                   as is_public_matching_funds

from schedule_i
