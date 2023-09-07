use pizza_runner;

DROP TABLE if exists row_split_customer_orders_temp;

CREATE
TEMPORARY TABLE row_split_customer_orders_temp AS
SELECT t.row_num,
       t.order_id,
       t.customer_id,
       t.pizza_id,
       trim(j1.exclusions) AS exclusions,
       trim(j2.extras) AS extras,
       t.order_time
FROM
  (SELECT *,
          row_number() over() AS row_num
   FROM customer_orders_temp) t
INNER JOIN json_table(trim(replace(json_array(t.exclusions), ',', '","')),
                      '$[*]' columns (exclusions varchar(50) PATH '$')) j1
INNER JOIN json_table(trim(replace(json_array(t.extras), ',', '","')),
                      '$[*]' columns (extras varchar(50) PATH '$')) j2 ;


SELECT *
FROM row_split_customer_orders_temp;


-- 1. What are the standard ingredients for each pizza?

drop table if exists standard_ingredients;
create temporary table standard_ingredients as 
select 
	pizza_name, 
    group_concat(topping_name) as standard_ingredients
from pizza_names
join pizza_recipes_temp as prt
using (pizza_id)
join pizza_toppings as pt
on prt.toppings = pt.topping_id
group by pizza_name
order by pizza_name;

select * from standard_ingredients;


-- 2. What was the most commonly added extra?
select 
	extras as topping_id,
	topping_name,
    count(extras) as number_of_times
from customer_orders_temp_2  as c
join pizza_toppings as pt
on c.extras = pt.topping_id
where extras is not null
group by extras, topping_name
order by number_of_times desc
limit 1;

-- 3. What was the most common exclusion?
select 
	exclusions as topping_id,
	topping_name,
    count(exclusions) as number_of_times
from customer_orders_temp_2  as c
join pizza_toppings as pt
on c.exclusions = pt.topping_id
where exclusions is not null
group by exclusions, topping_name
order by number_of_times desc;

-- 4. Generate an order item for each record in the `customers_orders` table in the format of one of the following
	 -- Meat Lovers
     -- Meat Lovers - Exclude Beef
     -- Meat Lovers - Extra Bacon
     -- Meat Lovers -- Exclude Cheese, Bacon - Extra Mushroom, Peppers

with cte as (
select 
	*, 
    topping_name as excluded_topping
from row_split_customer_orders_temp
left join pizza_names using (pizza_id)
left join pizza_toppings on topping_id = exclusions),

cte2 as (
select 
	row_num,
	pizza_name,
    order_id,
    customer_id,
    excluded_topping,
    pizza_toppings.topping_name as extra_topping
from cte
left join pizza_toppings on pizza_toppings.topping_id = extras)


select 
	order_id,
    customer_id,
    case 
		when excluded_topping is null 
			and extra_topping is null then pizza_name
		when excluded_topping is not null 
			and extra_topping is null then concat(pizza_name, ' - Exclude ', group_concat(DISTINCT excluded_topping))
		when extra_topping is not null 
			and excluded_topping is null then concat(pizza_name, ' - Extra ', group_concat(DISTINCT extra_topping))
		else concat(pizza_name, '- Exclude ', group_concat(DISTINCT excluded_topping), ' - Extra ', group_concat(DISTINCT extra_topping))
	end as order_item
from cte2 
group by order_id, customer_id, pizza_name, excluded_topping, extra_topping;

