-- REGION

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
select region,
	year,
    sum(case when changes = 'before' then sales end) as before_changes,
    sum(case when changes = 'after' then sales end) as after_changes
from cte
where changes is not null
group by year, region
order by year )

select 
	*,
    after_changes - before_changes as difference,
    round(100*(after_changes - before_changes)/before_changes, 2) as pct_change
from cte2
order by pct_change;

-- Asia had major negative impact in sales with -10.25% change after packaging and europe has comparatively least change with nearly negative 4% change


-- Platform

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
select platform,
	year,
    sum(case when changes = 'before' then sales end) as before_changes,
    sum(case when changes = 'after' then sales end) as after_changes
from cte
where changes is not null
group by year, platform
order by year )

select 
	*,
    after_changes - before_changes as difference,
    round(100*(after_changes - before_changes)/before_changes, 2) as pct_change
from cte2
order by pct_change;

-- Retail had a big impact with nearly -9.5% change, where as shopify has nearly -3.5% change



-- AGE_BAND

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
select age_band,
	year,
    sum(case when changes = 'before' then sales end) as before_changes,
    sum(case when changes = 'after' then sales end) as after_changes
from cte
where changes is not null
group by year, age_band
order by year )

select 
	*,
    after_changes - before_changes as difference,
    round(100*(after_changes - before_changes)/before_changes, 2) as pct_change
from cte2
order by pct_change;

-- DEMOGRAPHIC

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
select demographic,
	year,
    sum(case when changes = 'before' then sales end) as before_changes,
    sum(case when changes = 'after' then sales end) as after_changes
from cte
where changes is not null
group by year, demographic
order by year )

select 
	*,
    after_changes - before_changes as difference,
    round(100*(after_changes - before_changes)/before_changes, 2) as pct_change
from cte2
order by pct_change;

-- CUSTOMER-TYPE

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
select customer_type,
	year,
    sum(case when changes = 'before' then sales end) as before_changes,
    sum(case when changes = 'after' then sales end) as after_changes
from cte
where changes is not null
group by year, customer_type
order by year )

select 
	*,
    after_changes - before_changes as difference,
    round(100*(after_changes - before_changes)/before_changes, 2) as pct_change
from cte2
order by pct_change;


