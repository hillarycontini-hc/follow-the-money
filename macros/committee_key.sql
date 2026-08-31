{#
    Surrogate key for a committee version, with an explicit Unknown member.

    541 filing lines carry no committee ID, and others carry an ID with no name. Those
    contributions are real money that was really disclosed -- they simply cannot be
    attributed to a filer. Hashing nulls would mint a key that matches no dimension row,
    which turns a known gap into a broken join and drops the money from any query that
    inner-joins the dimension.

    So unattributable facts point at a declared Unknown member instead. The gap stays
    visible, referential integrity holds, and nobody has to remember to use an outer
    join to see the whole total.
#}
{% macro committee_key(committee_id, committee_name) %}
    case
        when {{ committee_id }} is null or {{ committee_name }} is null
            then '-1'
        else {{ dbt_utils.generate_surrogate_key([committee_id, committee_name]) }}
    end
{% endmacro %}
