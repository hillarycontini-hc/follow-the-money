{#
    Four definitions of "works in real-estate development", from narrow to broadest.

    Four rather than one because the answer moves with the definition, and hiding that
    behind a single blessed classifier would misrepresent how solid the finding is. The
    2021-22 spike survives all four (2.82x-3.01x and 3.55x-4.10x of baseline). The
    post-ban collapse does not survive any: 2024 reads 0.69x of baseline under the
    narrow definition and 1.55x under the standard one, which are opposite conclusions.
    See analyses/developer_sensitivity.sql and docs/adr/0002-developer-classifier.md.

    Classification runs on occupation rather than employer. Employer is free text with
    119,182 distinct values that normalise to only 107,886 -- a 9.5% reduction, with
    73,575 employers appearing exactly once and the top 1,000 reaching just 33.8% of
    dollars. There is no head to attack. Occupation has a usable head, reproduces the
    finding on its own, and adding employer matching moves totals by roughly 12%
    without changing the shape.

    is_developer_standard is the certified definition. The others exist to test it.
#}

{% macro developer_false_positives(occupation) %}
    {#
        Occupations that match a real-estate pattern but are not real-estate work.
        "Developer" is ambiguous between real estate and software; "development" is
        ambiguous between real estate and nonprofit fundraising. A naive '%develop%'
        sweeps in software developers, business-development managers, and directors of
        development at charities -- 133 rows of SOFTWARE DEVELOPER alone.
    #}
    {{ occupation }} in (
        'SOFTWARE DEVELOPER',
        'WEB DEVELOPER',
        'APPLICATION DEVELOPER',
        'BUSINESS DEVELOPMENT',
        'DEVELOPMENT DIRECTOR',
        'DIRECTOR OF DEVELOPMENT',
        'DEVELOPMENT',
        'DEVELOPMENT ASSOCIATE',
        'DEVELOPMENT MANAGER',
        'FUND DEVELOPMENT',
        'LANDSCAPE ARCHITECT'
    )
{% endmacro %}


{% macro is_developer_narrow(occupation) %}
    {# The occupation says developer, in those words. #}
    (
        not ({{ developer_false_positives(occupation) }})
        and {{ occupation }} in (
            'DEVELOPER',
            'REAL ESTATE DEVELOPER',
            'REAL ESTATE DEVELOPMENT',
            'PROPERTY DEVELOPER',
            'LAND DEVELOPER'
        )
    )
{% endmacro %}


{% macro is_developer_standard(occupation) %}
    {# Developers plus the rest of the real-estate profession. The certified definition. #}
    (
        not ({{ developer_false_positives(occupation) }})
        and (
            regexp_matches({{ occupation }}, 'REAL ESTATE')
            or {{ occupation }} like 'REALTOR%'
            or regexp_matches({{ occupation }}, '(^|[^A-Z])DEVELOPER([^A-Z]|$)')
        )
    )
{% endmacro %}


{% macro is_developer_broad(occupation) %}
    {# Adds property management and construction. #}
    (
        not ({{ developer_false_positives(occupation) }})
        and (
            regexp_matches({{ occupation }}, 'REAL ESTATE')
            or {{ occupation }} like 'REALTOR%'
            or regexp_matches({{ occupation }}, '(^|[^A-Z])DEVELOPER([^A-Z]|$)')
            or regexp_matches({{ occupation }}, 'PROPERT(Y|IES)')
            or regexp_matches({{ occupation }}, 'CONSTRUCTION')
            or regexp_matches({{ occupation }}, 'BUILDER')
            or regexp_matches({{ occupation }}, 'LAND USE')
        )
    )
{% endmacro %}


{% macro is_developer_broadest(occupation) %}
    {# Adds the design and contracting professions that live off development work. #}
    (
        not ({{ developer_false_positives(occupation) }})
        and (
            regexp_matches({{ occupation }}, 'REAL ESTATE')
            or {{ occupation }} like 'REALTOR%'
            or regexp_matches({{ occupation }}, '(^|[^A-Z])DEVELOP')
            or regexp_matches({{ occupation }}, 'PROPERT(Y|IES)')
            or regexp_matches({{ occupation }}, 'CONSTRUCTION')
            or regexp_matches({{ occupation }}, 'BUILDER')
            or regexp_matches({{ occupation }}, 'LAND USE')
            or regexp_matches({{ occupation }}, 'ARCHITECT')
            or regexp_matches({{ occupation }}, 'CONTRACTOR')
        )
    )
{% endmacro %}
