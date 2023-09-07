-- 01. What day of the week is used for each `week_date` value?
select 
	distinct(dayname(week_date))
from clean_weekly_sales;

-- Ans. Monday

-- 02. What range of week numbers are missing from the dataset?
select 
	distinct week_number, month
from clean_weekly_sales
order by week_number;

-- weeks from 1 to 11 (January to third week of March) 
-- and from first week of september to end of the year.

-- In simple words, from second week of september to third week of march, the dates are missing.

-- 3. How many total transactions were there for each year in the dataset?
select 
	year,
	sum(transactions) as transactions
from clean_weekly_sales
group by year
order by year;

-- 4. What is the total sales for each region for each month? 
select 
	region,
    month,
    monthname,
	sum(sales) as total_sales
from clean_weekly_sales
group by region, monthname, month
order by region, month;

-- Including Year
select 
	region,
    year,
    monthname,
	sum(sales) as total_sales
from clean_weekly_sales
group by region, monthname, year, month
order by region, year, month;

-- 5. What is the total count of transactions for each platform?
select 
	platform,
    sum(transactions) as 'number of transactions', 
    sum(sales) as 'sales by platform'
from clean_weekly_sales
group by platform;

-- 6. What is the percentage of sales for Retail vs Shopify for each month?
with cte as (
select
	monthname, month, year, platform,
    sum(sales) as total_sales_by_platform
from clean_weekly_sales
group by 1,2,3,4
order by 3, 2, 4),

cte2 as (
select 
	* , sum(total_sales_by_platform) over(partition by monthname, month, year) as total_sales
from cte
order by year, month, platform)

select 
	monthname, month, year,
    case
		when platform = 'Retail' then round(100*total_sales_by_platform/total_sales,2) 
	end as Retail_Percentage,
    case
		when platform = 'Shopify' then round(100*total_sales_by_platform/total_sales,2) 
	end as Shopify_Percentage
from cte2;

-- 7. What is the percentage of sales by demographic for each year in the dataset?
select 
	demographic,
    year,
    sum(sales),
    (select sum(sales) from clean_weekly_sales c2  where c1.year = c2.year group by year) as sales_by_year,
    round(100*sum(sales)/(select sum(sales) from clean_weekly_sales c2  where c1.year = c2.year group by year),2) as pct_of_sales
from clean_weekly_sales c1
group by demographic, year
order by year, demographic;

-- method 2
with sales_cte as (
select
	year,
    sum(case when demographic = 'Couples' then sales end) as couples_sales,
    sum(case when demographic = 'Families' then sales end) as family_sales,
    sum(case when demographic = 'unknown' then sales end) as unknown_sales,
    sum(sales) as total_sales
from clean_weekly_sales
group by 1
order by 1)

select 
	year,
    round(100*couples_sales/total_sales,2) as couples_sales_pct,
    round(100*family_sales/total_sales,2) as families_sales_pct,
    round(100*unknown_sales/total_sales,2) as unknown_sales_pct
from sales_cte;


-- 8. Which `age_band` and `demographic` values contribute the most to Retail Sales?
with cte as (
select
	age_band, 
    demographic, 
    sum(sales) as total_sales, 
    (select sum(sales) from clean_weekly_sales where platform = 'Retail') as overall_sales
from clean_weekly_sales
where platform = 'Retail'
group by age_band, demographic
order by age_band, demographic)

select 
	*,
    round(100*total_sales/overall_sales,2) as pct
from cte
order by pct desc;

-- Including Year
with cte as (
select
	year,
	age_band, 
    demographic, 
    sum(sales) as total_sales, 
    (select sum(sales) from clean_weekly_sales c2 where c1.year = c2.year) as overall_sales
from clean_weekly_sales c1
where platform = 'Retail'
group by age_band, demographic, year
order by year,age_band, demographic)

select 
	*,
    round(100*total_sales/overall_sales,2) as pct
from cte
order by year, pct desc;

-- 9. Can we use the avg_transaction column to find the average transaction size for each year
	-- for Retail vs Shopify? If not - how would you calculate it instead?
    
select 	
	year, platform,
	round(avg(avg_transaction),2) as avg_transaction_row,
    round(sum(sales)/sum(transactions),2) as avg_transaction_group
from clean_weekly_sales
group by year, platform
order by year, platform;

select * from clean_weekly_sales;












