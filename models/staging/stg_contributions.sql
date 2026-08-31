{{ config(materialized='view') }}

{#
    Typed, named and validated -- but not filtered. Every row that arrived is still
    here. Rows that cannot be trusted carry a flag rather than being dropped, so the
    count of bad data is queryable instead of invisible.
#}

with source as (

    select * from {{ source('raw', 'contributions') }}

),

typed as (

    select
        _content_key                                        as contribution_key,

        -- Dates -------------------------------------------------------------------
        {{ parse_filing_date('con_date') }}                 as contribution_date,
        con_date                                            as contribution_date_raw,
        {{ parse_filing_date('per_beg_date') }}             as period_begin_date,
        {{ parse_filing_date('per_end_date') }}             as period_end_date,
        {{ parse_filing_date('election_date') }}            as election_date,

        -- Money -------------------------------------------------------------------
        {{ parse_currency('con_amount') }}                  as amount,
        {{ parse_currency('con_amount_pd_forgiven') }}      as amount_paid_or_forgiven,

        -- Filing structure --------------------------------------------------------
        upper(trim(schedule))                               as schedule_code,
        trim(con_type)                                      as contribution_type,
        trim(con_desc)                                      as contribution_description,

        -- Contributor -------------------------------------------------------------
        nullif(trim(con_name), '')                          as contributor_name,
        nullif(trim(con_city_nm), '')                       as contributor_city,
        nullif(upper(trim(con_state_nm)), '')               as contributor_state,
        nullif(trim(con_occp), '')                          as contributor_occupation,
        nullif(trim(con_empr), '')                          as contributor_employer,

        -- ZIP codes lost their leading zeros upstream: 06511 arrives as 6511. Only
        -- pad values that are purely numeric and short, so ZIP+4 and the various
        -- malformed entries survive untouched.
        case
            when nullif(trim(con_zip_cd), '') is null then null
            when regexp_matches(trim(con_zip_cd), '^[0-9]{1,4}$')
                then lpad(trim(con_zip_cd), 5, '0')
            else trim(con_zip_cd)
        end                                                 as contributor_zip,

        -- Committee ---------------------------------------------------------------
        nullif(trim(cmt_id), '')                            as committee_id,
        nullif(trim(cmt_nm), '')                            as committee_name,
        nullif(upper(trim(cmt_type)), '')                   as committee_type_code,
        nullif(trim(cand_name), '')                         as candidate_name,
        nullif(trim(seat_desc), '')                         as office,
        nullif(trim(dist_num), '')                          as district,
        nullif(trim(election_desc), '')                     as election_description,

        {#
            Intermediary ------------------------------------------------------------

            int_state_nm is deliberately absent. It is 100% null in the source, and the
            loader does not create a column it has never seen a value for -- so the
            landing table's shape is a function of the data, not of the publisher's
            declared schema. Referencing it fails at compile time with "column not
            found", which is the correct behaviour but an alarming way to discover it.

            If the publisher ever populates that field, the column will appear and this
            model will keep ignoring it. That is the trade-off taken knowingly:
            int_name (27,847 rows, $11.0M), int_occp (105) and int_empr (79) are all
            live and are carried through.
        #}
        nullif(trim(int_name), '')                          as intermediary_name,
        nullif(trim(int_city_nm), '')                       as intermediary_city,
        nullif(trim(int_zip_cd), '')                        as intermediary_zip,
        nullif(trim(int_occp), '')                          as intermediary_occupation,
        nullif(trim(int_empr), '')                          as intermediary_employer,

        nullif(trim(memo), '')                              as memo,
        _ingested_at                                        as ingested_at

    from source

),

classified as (

    select
        *,

        case schedule_code
            when 'A' then 'Monetary contribution'
            when 'B' then 'Loan received'
            when 'C' then 'Non-monetary (in-kind) contribution'
            when 'I' then 'Miscellaneous increase to cash'
        end                                                 as schedule_name,

        {#
            The itemised/unitemised split cannot be read off a clean label. Schedule A
            spells it "Monetary Contributions (Untemized)" -- no "i" -- while B, C and I
            spell it correctly, and Schedule I additionally alternates between "Misc.
            Increase to Cash" and "Misc. Increases to Cash". A filter on '%Unitemized%'
            silently misses all 7,064 Schedule A aggregate rows, which hold
            $170,731,012.

            Anything that matches neither pattern lands as NULL and trips the not_null
            test, so a new spelling upstream breaks the build instead of quietly
            reclassifying a third of a billion dollars.
        #}
        case
            when regexp_matches(lower(contribution_type), '\(un-?i?temized\)') then false
            when regexp_matches(lower(contribution_type), '\(itemized\)')      then true
        end                                                 as is_itemized,

        {{ is_plausible_filing_date('contribution_date') }}  as has_plausible_date

    from typed

)

select * from classified
