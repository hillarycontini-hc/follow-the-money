{#
    Parse a disclosed date into a DATE.

    Socrata declares these columns as calendar_date and serves them as
    "2003-06-16T00:00:00.000". Letting a loader infer the type yields a timestamp with a
    timezone, which shifts every value back seven hours in this locale and moves
    contributions across day boundaries -- and therefore across reporting periods and
    election cycles. Taking the leading date component explicitly avoids the whole class
    of problem.
#}
{% macro parse_filing_date(column) %}
    try_cast(left(trim(cast({{ column }} as varchar)), 10) as date)
{% endmacro %}
