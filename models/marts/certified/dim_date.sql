{{ config(materialized='table') }}

{#
    Conformed date dimension, role-played by every fact in the project.

    fct_contribution joins it as the contribution date; fct_loan_snapshot joins it as
    the period end date; dim_committee holds an election date drawn from the same spine.
    One dimension, three roles -- which is the point of conforming it rather than
    letting each fact grow its own date columns.

    LA city elections moved from odd years to even years with the 2020 cycle, so
    "election year" cannot be derived from parity and is flagged explicitly.
#}

with spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2001-01-01' as date)",
        end_date="cast('2027-12-31' as date)"
    ) }}

),

dates as (

    select cast(date_day as date) as date_day
    from spine

)

select
    date_day                                            as date_key,
    date_day,

    extract(year from date_day)::int                    as calendar_year,
    extract(month from date_day)::int                   as calendar_month,
    extract(day from date_day)::int                     as day_of_month,
    extract(quarter from date_day)::int                 as calendar_quarter,
    strftime(date_day, '%Y-%m')                         as calendar_month_key,
    date_trunc('month', date_day)::date                 as first_day_of_month,
    date_trunc('year', date_day)::date                  as first_day_of_year,

    -- LA city general elections: odd years through 2017, even years from 2020 as the
    -- city consolidated with statewide dates.
    extract(year from date_day)::int in (
        2001, 2003, 2005, 2007, 2009, 2011, 2013, 2015, 2017,
        2020, 2022, 2024, 2026
    )                                                   as is_city_election_year,

    -- The 2019 developer-contribution ordinance was adopted 2019-12-04 but did not bind
    -- until after the March 2022 primary. Both dates matter, and neither is derivable,
    -- so they are declared here rather than hard-coded into whichever model needs them.
    date_day >= date '2019-12-04'                       as is_after_developer_ban_adopted,
    date_day >= date '2022-03-09'                       as is_after_developer_ban_effective

from dates
