use pizza_runner;
-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
	-- how much money has Pizza Runner made so far if there are no delivery fees?

drop table if exists price_table;
create temporary table price_table as (
select *,
	case when pizza_name = 'Meatlovers' then 12 else 10 end as price 
from customer_orders_temp
inner join pizza_names using (pizza_id)
inner join runner_orders_temp using (order_id)
where pickup_time is not null);

select sum(price) from price_table;

-- 2. What if there was an additional $1 charge for any pizza extras?
	-- Add cheese is $1 extra
    
with cte as (
SELECT *,
	case when pizza_id = 1 then 12 else 10 end as pizza_price,
	length(extras) - length(replace(extras, ",", ""))+1 AS topping_count
FROM customer_orders_temp
INNER JOIN pizza_names USING (pizza_id)
INNER JOIN runner_orders_temp USING (order_id)
WHERE cancellation IS NULL
ORDER BY order_id)


select pizza_revenue + toppings_revenue as total_revenue
from (
select 
	sum(pizza_price) as pizza_revenue, 
    sum(topping_count) as toppings_revenue
from cte) t;

-- 3. If Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner,
	-- how would you design an additional table for this new dataset
    -- generate a schema for this new table 
    -- and insert your own data for ratings for each successful customer order between 1 to 5
    
drop table if exists order_rating;

create table order_rating (
	order_id integer,
    rating enum('1','2','3','4','5') not null,
    review varchar(225),
    rating_time timestamp);

insert into 
	order_rating (order_id, rating, review, rating_time)
values
	(1, 2, '', now()),
    (2, 5, 'Really Fast delivery', now()),
    (3, 1, 'Delivery was late, food got cold', now());
    
select * from order_rating;

-- 4. Using your newly generated table - can you join all of the information together to form 
--  a table which has the following information for successful deliveries;

-- customer_id, order_id, runner_id, rating, order_time, pickup_time
-- time b/w order and pickup, delivery duration, average speed, total number of pizzas

drop table if exists successful_deliveries;
create temporary table successful_deliveries as (
select 
	customer_id,
    order_id,
    runner_id,
    rating,
    order_time,
    pickup_time,
	timestampdiff(second, order_time, pickup_time)/60 as time_diff_in_min,
    distance,
    duration as delivery_duration,
    round((distance*1000)/(duration*60),2) as avg_speed_in_meters_per_sec,
    count(pizza_id) as number_of_pizzas
from customer_orders_temp
join runner_orders_temp
using (order_id)
left join order_rating
using (order_id)
where cancellation is null
group by order_id, customer_id, runner_id, pickup_time, order_time, rating, duration, distance);

select * from successful_deliveries;

-- 5. If a Meat Loves pizza was $12 and Vegetarian $10 fixed prices with no cost for extras 
	-- and each runner is paid $0.30 per kilometer travelled - how much money does pizza Runner have left over after these deliveries?

drop table if exists revenue;

create temporary table revenue as (
select 
	*,
    case when pizza_name = 'Meatlovers' then 12 else 10 end as price
from customer_orders_temp
join runner_orders_temp using (order_id)
join pizza_names using (pizza_id)
where cancellation is null);


drop table if exists cost;

create temporary table cost as (
select 
	distinct order_id, customer_id, order_time, runner_id, distance,
    round((distance*0.30),2) as runner_cost
from customer_orders_temp
join runner_orders_temp using (order_id)
where cancellation is null);

with total as (
select sum(price) as total_revenue
from revenue),

minus as (
select sum(runner_cost) as expense from cost)

select (total_revenue - expense) as net_remaining
from total
join minus



