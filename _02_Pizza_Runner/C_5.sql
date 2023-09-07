-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the
-- customer_orders table and add a 2x in front of any relevant ingredients

use pizza_runner;
drop table if exists std_ingredients;

create temporary table if not exists std_ingredients as (
select  distinct 
	order_id,
    customer_id,
    c.pizza_id,
    order_time,
    topping_name as standard_ingredients
from customer_orders_temp_2 c
left join pizza_recipes_temp r
on r.pizza_id = c.pizza_id
left join pizza_toppings t
on t.topping_id  = r.toppings
order by customer_id);

select * from std_ingredients;

drop table if exists excluded_toppings;

create temporary table if not exists excluded_toppings as (
select distinct  
	order_id,
    customer_id,
    pizza_id,
    order_time,
	topping_name as exclusions
from customer_orders_temp_2
join pizza_recipes_temp using (pizza_id)
join pizza_toppings t
on t.topping_id = exclusions
where exclusions is not null
order by customer_id);

drop table if exists extra_toppings;

create temporary table if not exists extra_toppings as (
select distinct
	order_id,
    customer_id,
    pizza_id,
    order_time,
    topping_name as extras
from customer_orders_temp_2
join pizza_recipes_temp using (pizza_id)
join pizza_toppings t
on t.topping_id = extras
where extras is not null
order by customer_id);

drop table if exists std_and_excluded;
create temporary table std_and_excluded as (
select * from std_ingredients
except 
select * from excluded_toppings);

drop table if exists complete;
create temporary table complete as (
select 
	*
from std_and_excluded
union all
select * from extra_toppings);

drop table if exists final_table;
create temporary table final_table as (
select
	*, 
    count(standard_ingredients) as n
from complete
join pizza_names using (pizza_id)
group by order_id, customer_id, pizza_id, order_time, standard_ingredients, pizza_name
order by order_id);

select * from final_table;

with cte as (
select 
	pizza_id,
    order_id,
    customer_id,
    order_time,
    pizza_name,
    case
		when n > 1 then concat(n, " X ", standard_ingredients)
		when n = 1 then group_concat(standard_ingredients) 
	end as final
from final_table
group by pizza_id, order_id, customer_id, order_time, pizza_name, n, standard_ingredients
order by order_id, final),

cte2 as (
select pizza_id, order_id, customer_id, order_time, 
	case 
		when pizza_name = 'Meatlovers' then 'Meat Lovers: '
        else 'Vegetarian: ' end as pizza_name,
	group_concat(final) as final_ingredients
from cte
group by order_id, pizza_id, customer_id, order_time, pizza_name)

select 
	order_id, customer_id, pizza_id,
	concat(pizza_name, final_ingredients) as final_list
from cte2;