-- Regression test: the contributions fact must never contain loans, public financing,
-- or period aggregates.
--
-- This is the single most likely way for this project's headline number to become
-- wrong, and it would happen in the most ordinary way imaginable: someone widens a
-- filter to "include everything" while chasing a total that looks too low. The result
-- would add $127.3M of loans and $54.6M of public matching funds to a figure labelled
-- "contributions received", plus $170.7M of period aggregates that double-count the
-- itemised rows they summarise.
--
-- The assertion is structural rather than a pinned dollar value on purpose. The source
-- refreshes daily, so any hard-coded total would fail every morning for reasons that
-- have nothing to do with correctness, and a test that cries wolf gets deleted. What
-- cannot legitimately change is which schedules belong at this grain.

select
    schedule_code,
    contribution_type,
    count(*)     as offending_rows,
    sum(amount)  as offending_amount
from {{ ref('fct_contribution') }}
where schedule_code not in ('A', 'C')
   or contribution_type is null
   or regexp_matches(lower(contribution_type), '\(un-?i?temized\)')
group by schedule_code, contribution_type
