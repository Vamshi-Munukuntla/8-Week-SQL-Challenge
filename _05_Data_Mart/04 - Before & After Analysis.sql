use data_mart;
-- 1. What is the total sales for the 4 weeks before and after 2020-06-15?
-- What is the growth reduction rate in actual values and percentage of sales?

select 
	*
from clean_weekly_sales
where week_date = '2020-06-15';

-- week numbers - 24,23,22,21 - before sales for 4 weeks
-- week numbers - 25,26,27,28 - after sales for 4 weeks

-- Using Pivot Table

with cte as (
select 
	*, 
    case
		-- when week_number between 21 and 24 then 'before'
--         when week_number between 25 and 28 then 'after'
		when week_date between date_add('2020-06-15', interval -3 week) and '2020-06-15' then 'before'
        when week_date between '2020-06-16' and date_add('2020-06-16', interval 4 week) then 'after'
        else null
	end as changes
from clean_weekly_sales
where year = 2020),

cte2 as (
select 
	year,
    sum(case when changes = 'before' then sales end) as before_changes,
    sum(case when changes = 'after' then sales end) as after_changes
from cte
where changes is not null
group by year
order by year )

select 
	*,
    after_changes - before_changes as difference,
    round(100*(after_changes - before_changes)/before_changes, 2) as pct_change
from cte2;

-- 2. what about the entire 12 weeks before and afte?

with cte as (
select 
	*, 
    case
		when week_date between date_add('2020-06-15', interval -11 week) and '2020-06-15' then 'before'
        when week_date between '2020-06-16' and date_add('2020-06-16', interval 12 week) then 'after'
        else null
	end as changes
from clean_weekly_sales),

cte2 as (
select 
	year,
    sum(case when changes = 'before' then sales end) as before_changes,
    sum(case when changes = 'after' then sales end) as after_changes
from cte
where changes is not null
group by year
order by year )

select 
	*,
    after_changes - before_changes as difference,
    round(100*(after_changes - before_changes)/before_changes, 2) as pct_change
from cte2;


-- 3.How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

-- for 4 weeks

with cte as (
select 
	*, 
    case
		when week_number between 21 and 24 then 'before'
        when week_number between 25 and 28 then 'after'
        else null
	end as changes
from clean_weekly_sales),

cte2 as (
select 
	year,
    sum(case when changes = 'before' then sales end) as before_changes,
    sum(case when changes = 'after' then sales end) as after_changes
from cte
where changes is not null
group by year
order by year )

select 
	*,
    after_changes - before_changes as difference,
    round(100*(after_changes - before_changes)/before_changes, 2) as pct_change
from cte2;

-- for 12 weeks
with cte as (
select 
	*, 
    case
		when week_number between 13 and 24 then 'before'
        when week_number between 25 and 37 then 'after'
        else null
	end as changes
from clean_weekly_sales),

cte2 as (
select 
	year,
    sum(case when changes = 'before' then sales end) as before_changes,
    sum(case when changes = 'after' then sales end) as after_changes
from cte
where changes is not null
group by year
order by year )

select 
	*,
    after_changes - before_changes as difference,
    round(100*(after_changes - before_changes)/before_changes, 2) as pct_change
from cte2;

