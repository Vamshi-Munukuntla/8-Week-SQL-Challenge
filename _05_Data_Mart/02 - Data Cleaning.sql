use data_mart;

drop table if exists clean_weekly_sales;

create table if not exists clean_weekly_sales as (
with format_dates as (
select 
	*, 
	str_to_date(week_date, '%d/%m/%Y') as formatted_week_date
from weekly_sales)

select 
	formatted_week_date as week_date,
	week(formatted_week_date) as week_number,
    month(formatted_week_date) as month,
    monthname(formatted_week_date) as monthname,
    year(formatted_week_date) as year,
    case 
		when segment = 'null' then null else segment end as segment,
	case 
		when right(segment,1) = '1' then 'Young Adults'
        when right(segment, 1) = '2' then 'Middle Aged'
        when right(segment,1) = '3' or right(segment,1) = '4' then 'Retirees'
        else 'unknown'
        end as age_band,
	case 
		when left(segment,1) = 'C' then 'Couples'
        when left(segment,1) = 'F' then 'Families'
        else 'unknown'
        end as demographic,
    region,
    platform,
    customer_type,
    sales,
    transactions,
    round(sales/transactions,2) as avg_transaction
from format_dates);

select * from clean_weekly_sales;










