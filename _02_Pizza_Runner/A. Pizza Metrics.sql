use pizza_runner;

-- 1. How many pizzas were ordered?
select 
	count(*) as orders_made
from customer_orders_temp;

-- 2. How many unique customer orders were made?
select 
	count(*) as unique_orders
from (
select 
	distinct order_id, customer_id
from customer_orders_temp) t;

-- 3. How many successful orders were delivered by each runner?
select
	runner_id,
	count(*) as succesful_deliveries
from runner_orders_temp
where pickup_time is not null
group by runner_id;

-- 4. How many of each type of pizza was delivered?
select 
    pizza_name,
	count(c.pizza_id) as number_of_orders_made
from customer_orders_temp as c
join runner_orders_temp r
on r.order_id = c.order_id
join pizza_names as p
on c.pizza_id = p.pizza_id
where pickup_time is not null
group by c.pizza_id, pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
select 
	customer_id,
    pizza_name,
    count(p.pizza_id) as order_count
from customer_orders_temp c
join pizza_names p
on c.pizza_id = p.pizza_id
group by customer_id, p.pizza_name
order by customer_id, p.pizza_name;

-- 6. What was the maximum number of pizzas delivered in a single order?

select 
	order_id,
    count(pizza_id) as number_of_pizzas
from customer_orders_temp
group by order_id
order by number_of_pizzas desc
limit 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

with cte as (
select 
	customer_id,
    case
		when exclusions is not null then 'Yes'
        when extras is not null then 'Yes'
        else 'No'
	end as changes_made
from customer_orders_temp c
join runner_orders_temp r
on c.order_id = r.order_id
where pickup_time is not null)

select 
	customer_id,
    changes_made,
    count(changes_made) as orders
from cte
group by customer_id, changes_made
order by customer_id, changes_made;

-- 8. How many pizzas were delivered that had both exclusions and extras?

select count(changes) as number_of_successful_deliveries
from (
select 
    case
		when exclusions is not null and extras is not null then 'Yes'
	end as changes
from customer_orders_temp c
join runner_orders_temp r
on c.order_id = r.order_id
where pickup_time is not null) t;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
select 
    hour(order_time) as hour_of_day,
    count(pizza_id) as order_volume
from customer_orders_temp
group by hour(order_time)
order by hour_of_day;

-- 10. What was the volume of orders for each day of the week?
select 
	day(order_time) as day,
    dayname(order_time) as day_name,
    count(distinct order_id) as order_volume
from customer_orders_temp 
group by day_name, day
order by day;

select 
    dayname(order_time) as day_name,
    count(distinct order_id) as order_volume
from customer_orders_temp 
group by day_name
order by day_name;





