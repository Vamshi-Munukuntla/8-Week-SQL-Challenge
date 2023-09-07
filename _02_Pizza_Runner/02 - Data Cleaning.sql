use pizza_runner;
-- CLEANING CUSTOMER_ORDERS TABLE

DROP TABLE if exists customer_orders_temp;

create temporary table customer_orders_temp as 
select 
	order_id,
    customer_id,
    pizza_id,
    
    -- CLEANING EXCLUSIONS COLUMN
    case when exclusions = '' then NULL
		 when exclusions = 'null' then NULL
         else exclusions
	end as exclusions,
    
    -- CLEANING EXTRAS COLUMN
    case when extras = '' then NULL
		 when extras = 'null' then NULL
         else extras
	end as extras,
    
    order_time
from customer_orders;

select * from customer_orders_temp;

-----------------------------------------------------------------

-- CLEANING RUNNER_ORDERS TABLE
drop table if exists runner_orders_temp; 

create temporary table runner_orders_temp as 
select 
	order_id,
    runner_id,
    -- PICKUP_TIME column
    case 
		when pickup_time ='null' then NULL
		else pickup_time
    end as pickup_time,
    
    -- DISTANCE column
    case 
		when distance = 'null' then NULL
        else cast(regexp_replace(distance, '[a-z]+', '') as float)
	end as distance,
    
    -- DURATION COLUMN
    case 
		when duration = 'null' then NULL
        else cast(regexp_replace(duration, '[a-z]+', '') as float)
	end as duration,
    
    -- CANCELLATION column
    case
		when cancellation = 'null' then NULL
        when cancellation = '' then null
        ELSE cancellation
	end as cancellation
from runner_orders;

select * from runner_orders_temp;
		
select
	*,
    json_array(toppings),
    replace(json_array(toppings), ',', '","'),
    trim(replace(json_array(toppings), ',', '","'))
from pizza_recipes;
		
drop table if exists pizza_recipes_temp;

create temporary table pizza_recipes_temp as
SELECT 
	t.pizza_id, 
    cast(j.topping as float) as toppings
FROM pizza_recipes t
JOIN json_table(trim(replace(json_array(t.toppings), ',', '","')), '$[*]' columns (topping varchar(50) PATH '$')) j ;

select * from pizza_recipes_temp;


drop table if exists customer_orders_temp_2;

create temporary table customer_orders_temp_2 as 
SELECT t.order_id,
       t.customer_id,
       t.pizza_id,
       trim(j1.exclusions) AS exclusions,
       trim(j2.extras) AS extras,
       t.order_time
FROM customer_orders_temp t
INNER JOIN json_table(trim(replace(json_array(t.exclusions), ',', '","')), '$[*]' columns (exclusions varchar(50) PATH '$')) j1
INNER JOIN json_table(trim(replace(json_array(t.extras), ',', '","')), '$[*]' columns (extras varchar(50) PATH '$')) j2 ;

select * from customer_orders_temp_2

