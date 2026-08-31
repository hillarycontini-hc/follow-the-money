{#
    Whether a parsed date could plausibly be a filing in this dataset.

    The dataset covers October 2001 onward, but contains dates of 0121-03-08,
    1409-08-01 and 1973-05-31 among others. These are upstream data-entry errors, not
    edge cases to be modelled. They are quarantined rather than dropped so that the
    count of rejected rows is visible and testable instead of being absorbed silently at
    the ingest boundary.
#}
{% macro is_plausible_filing_date(column) %}
    {#
        coalesce is load-bearing. A NULL date compared with BETWEEN yields NULL, not
        false, so without it the 24 dateless rows produce a NULL flag -- and "is this
        row usable?" becomes a three-valued question that every downstream filter has to
        remember to handle. They are not plausible; say so.
    #}
    coalesce(
        {{ column }} between date '1990-01-01' and (current_date + interval '1 year'),
        false
    )
{% endmacro %}
