{#
    Parse a disclosed money amount into a decimal.

    The same column arrives in two different shapes depending on how the dataset is
    obtained. The Socrata API returns con_amount as "500.00". The CSV export of the same
    column returns "$1,000.00" -- every one of the 418,748 values carries a currency
    symbol and thousands separators, so a bare cast fails on 100% of rows. Negative
    amounts are real (refunds and redesignations, down to -$1,102,954.14) and must
    survive parsing rather than being clamped away.
#}
{% macro parse_currency(column) %}
    try_cast(
        nullif(
            regexp_replace(trim(cast({{ column }} as varchar)), '[$,[:space:]]', '', 'g'),
            ''
        ) as decimal(18, 2)
    )
{% endmacro %}
