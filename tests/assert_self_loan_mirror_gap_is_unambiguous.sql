-- Regression test: self-loan mirror detection must stay on exact equality.
--
-- The mirror rule excludes a contributor from money totals when their giving to a
-- committee is matched *exactly* by a loan on Schedule B. The obvious "improvement"
-- someone will eventually propose is a tolerance band -- 0.95 to 1.05, say -- on the
-- grounds that exact float comparison is brittle.
--
-- That change would quietly delete real donations, and this test is what stops it.
--
-- An earlier version of this test asserted that a clean gap separated mirrors from
-- everything else. That was wrong, and measuring it is what proved it wrong: the
-- distribution is continuous right up to the boundary. Of 149 contributor/committee
-- pairs that both gave and lent, 21 sit at exactly 1.0000; the nearest below is
-- 0.996401 and the nearest above is 1.000309. There is no empty space to hide in.
--
-- So exactness is not a convenience, it is the whole rule. A pair at 0.996401 --
-- Warren T. Furutani, who gave $17,600.61 and lent $17,537.26 -- is not a double-booked
-- disclosure. Those are two different amounts, which means two different transactions:
-- a real gift and a real loan. A ±1% tolerance would capture that pair and erase a
-- genuine $17,600 contribution from every total in the project. A ±5% band reaches
-- Wendy Greuel at 0.989558 and Ankur Patel at 0.980198, and so on outward.
--
-- Equality means the same money disclosed twice. Approximate equality means two
-- different sums that happen to be close, which is exactly what a committee's treasurer
-- would produce in the ordinary course of business.

with mirrors as (

    select
        committee_id,
        contributor_name,
        schedule_a_total,
        schedule_b_total,
        mirror_ratio
    from {{ ref('int_self_loan_mirrors') }}

),

exactness_violations as (

    -- Any mirror whose two sides are not identical means the rule has been loosened.
    select
        committee_id,
        contributor_name,
        schedule_a_total,
        schedule_b_total,
        mirror_ratio,
        'mirror rule is no longer exact equality' as failure_reason
    from mirrors
    where schedule_a_total <> schedule_b_total
       or mirror_ratio <> 1.0

),

loaded_scale as (

    -- How much of the dataset is actually present. CI loads a bounded window rather
    -- than all 418,748 rows, and the population check below is only meaningful against
    -- a full load.
    select count(*) as fact_rows from {{ ref('fct_contribution') }}

),

population_violations as (

    -- A rule change that empties or explodes the mirror set is also a failure, even if
    -- each surviving row is individually exact. Observed population is 21 over the full
    -- dataset.
    --
    -- The assertion is gated on scale rather than softened, because an absolute band is
    -- simply the wrong question to ask of a partial load: a single recent year contains
    -- only a handful of committee/contributor pairs that both gave and lent, and
    -- failing on that would teach everyone to ignore this test. Exactness above is
    -- checked unconditionally and is the assertion that actually guards the rule.
    select
        null::varchar as committee_id,
        null::varchar as contributor_name,
        null::decimal(18, 2) as schedule_a_total,
        null::decimal(18, 2) as schedule_b_total,
        null::double as mirror_ratio,
        'mirror population moved outside its expected band: '
            || count(*)::varchar || ' pairs' as failure_reason
    from mirrors
    cross join loaded_scale
    group by loaded_scale.fact_rows
    having loaded_scale.fact_rows > 300000
       and (count(*) < 10 or count(*) > 60)

)

select * from exactness_violations
union all
select * from population_violations
