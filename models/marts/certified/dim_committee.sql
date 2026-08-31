{{ config(materialized='table') }}

{#
    Type 2 committee dimension. One row per committee identity *version*.

    A committee ID is not a stable label. Committee 1319104 files under three different
    names across three election cycles -- supporting one candidate in 2013 and opposing
    another in 2024 -- and UTLA's 1393480 files under seven. Collapsing these to the most
    recent name is not a simplification, it is a factual error: it would report money
    raised for a 2013 mayoral campaign as having been raised by a 2024 committee opposing
    a council member.

    The history is already present in the filings -- every row carries the committee name
    as it stood when the contribution was disclosed -- so the versions are derived rather
    than snapshotted. A dbt snapshot would only capture changes occurring after we
    started watching, which is exactly the wrong window for a dataset that begins in 2001.
#}

with filings as (

    select
        committee_id,
        committee_name,
        committee_type_code,
        candidate_name,
        office,
        district,
        election_date,
        election_description,
        contribution_date
    from {{ ref('stg_contributions') }}
    where committee_id is not null
      and committee_name is not null
      and has_plausible_date

),

versions as (

    select
        committee_id,
        committee_name,

        -- Committee attributes are taken as the modal value within the version rather
        -- than the first seen, so a single mistyped filing cannot rename a committee.
        mode(committee_type_code)   as committee_type_code,
        mode(candidate_name)        as candidate_name,
        mode(office)                as office,
        mode(district)              as district,

        -- Election date is an attribute of the committee, not of the contribution:
        -- 975 of 988 committee IDs carry exactly one. It is held here so that no fact
        -- table is tempted to join a contribution date to an election date directly.
        mode(election_date)         as election_date,
        mode(election_description)  as election_description,

        min(contribution_date)      as first_filing_date,
        max(contribution_date)      as last_filing_date,
        count(*)                    as filing_line_count

    from filings
    group by committee_id, committee_name

),

sequenced as (

    select
        *,
        row_number() over (
            partition by committee_id order by first_filing_date, committee_name
        ) as version_number,
        lead(first_filing_date) over (
            partition by committee_id order by first_filing_date, committee_name
        ) as next_version_starts

    from versions

)

select
    {{ committee_key('committee_id', 'committee_name') }}
        as committee_key,
    committee_id,
    committee_name,
    version_number,

    committee_type_code,
    case committee_type_code
        when 'C' then 'Candidate controlled'
        when 'O' then 'Officeholder'
        when 'B' then 'Ballot measure'
        when 'P' then 'Primarily formed'
        when 'G' then 'General purpose'
    end as committee_type_name,

    -- P and G committees are the independent-expenditure vehicles. They carry no
    -- contribution limits, which is why they hold 39% of the money in 2.6% of the rows.
    committee_type_code in ('P', 'G') as is_independent_expenditure_type,

    candidate_name,
    office,
    district,
    election_date,
    election_description,

    first_filing_date as valid_from,

    -- Half-open interval: valid_to is the instant the next version begins, or open.
    next_version_starts as valid_to,
    next_version_starts is null as is_current_version,

    last_filing_date,
    filing_line_count

from sequenced

union all

{#
    The Unknown member. Facts that cannot be attributed to a filer point here rather
    than at a key that matches nothing. Declared explicitly so that "unattributed" is a
    value someone can group by and see, not an absence they have to notice.
#}
select
    '-1'                        as committee_key,
    '-1'                        as committee_id,
    'Unknown committee'         as committee_name,
    0                           as version_number,
    null                        as committee_type_code,
    'Unknown'                   as committee_type_name,
    false                       as is_independent_expenditure_type,
    null                        as candidate_name,
    null                        as office,
    null                        as district,
    null                        as election_date,
    null                        as election_description,
    date '1900-01-01'           as valid_from,
    null                        as valid_to,
    true                        as is_current_version,
    null                        as last_filing_date,
    0                           as filing_line_count
