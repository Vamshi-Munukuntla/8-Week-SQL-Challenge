use pizza_runner;
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select 
    week(registration_date) as 'Registered Week', 
    count(week(registration_date)) as 'Number of Runners'
from runners
group by week(registration_date);
	
-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
with cte as 
(select
	c.order_id, customer_id, pizza_id, runner_id,
    time_to_sec(timediff(pickup_time, order_time)) as time_duration
from customer_orders_temp c
join runner_orders_temp r
on r.order_id = c.order_id
where pickup_time is not null),

cte2 as (
select 
	runner_id,
    sum(time_duration) as total_time_in_seconds,
    count(runner_id) as number_of_orders
from cte
group by runner_id)

select 
	runner_id,
    (total_time_in_seconds/number_of_orders)/60 as avg_time_per_order
from cte2;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
with cte as (
select 
	order_id,
    count(order_id) as pizza_count,
    timestampdiff(second, order_time, pickup_time) as prep_time
from customer_orders_temp
inner join runner_orders_temp 
using (order_id)
where pickup_time is not null
group by order_id, prep_time)

select 
	pizza_count,
    count(pizza_count),
    avg(prep_time)/60
from cte
group by pizza_count;


-- 4. What was the average distance travelled for each customer?

select 
	customer_id,
    round(avg(distance),2) as avg_kms_travelled
from customer_orders_temp c
join runner_orders_temp r
using (order_id)
where pickup_time is not null
group by customer_id;

-- 5.What was the difference between the longest and shortest delivery times for all orders?
select
	min(duration) as shortest_delivery,
    max(duration) as longest_delivery,
    max(duration) - min(duration) as max_diff
from runner_orders_temp;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
select 
	runner_id,
    order_id,
    distance, 
    duration,
    round(distance/duration,2)*60 as avg_speed
from runner_orders_temp
where pickup_time is not null
order by runner_id;

-- What is the successful delivery percentage for each runner?
with cte as (
select 
	runner_id,
    case 
		when cancellation is null then 1 else 0
	end as delivery_status
from runner_orders_temp),

cte2 as(
select 
	runner_id,
    sum(delivery_status) as successful_deliveries,
	count(delivery_status) as number_of_deliveries
from cte
group by runner_id
order by runner_id)

select 
	runner_id,
	round((successful_deliveries/number_of_deliveries)*100) as 'success%'
from cte2

