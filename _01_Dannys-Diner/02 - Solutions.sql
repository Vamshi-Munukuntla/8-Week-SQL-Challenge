USE dannys_diner;
-- What is the total amount each customer spent at the restaurant?
select 
	s.customer_id,
	sum(price) as amount_spent
from menu as m
inner join sales as s
on m.product_id = s.product_id
group by customer_id;


-- 2. How many days has each customer visited the restaurant?
select 
	customer_id,
    count(distinct order_date) as visited_days
from sales
group by customer_id;


-- 3. What was the first item from the menu purchased by each customer?
with orders as (
select 
	s.customer_id,
    s.order_date,
    s.product_id,
    m.product_name,
    m.price,
dense_rank() over(partition by customer_id order by order_date) as rnk_order
from sales s
inner join menu m
on s.product_id = m.product_id)

select distinct 
	customer_id,
    product_name
from orders
where rnk_order = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

-- # METHOD 1 - using WINDOW FUNCTIONS AND CTE & JOINS
with orders as (
select 
	customer_id,
    order_date,
    sales.product_id,
    product_name,
    price,
row_number() over(partition by product_name) as order_count
from sales
inner join menu
on menu.product_id = sales.product_id)

select 
	product_name,
    max(order_count) as number_of_orders
from orders
group by product_name
order by number_of_orders desc
limit 1;


-- # METHOD 2 - using CTE & JOINS
with cte as (
select 
	product_id, 
    count(product_id) as orders
from sales
group by product_id)

select 
	product_name, 
    orders
from cte
join menu
on menu.product_id = cte.product_id
order by orders desc
limit 0,1;


-- # METHOD 3 -- using GROUP BY & JOINS
select
	product_name,
	count(s.product_id) as number_of_orders
from sales as s
inner join menu as m
on m.product_id = s.product_id
group by m.product_name
order by number_of_orders desc
limit 1;


-- 5. Which item was the most popular for each customer?
with cte as 
(select 
	customer_id, product_id,
    count(product_id) as orders
from sales
group by customer_id, product_id
order by customer_id, product_id),

cte2 as (
select 
*,
rank() over(partition by customer_id order by orders desc) as rnk_order
from cte)

select 
	customer_id,
    product_name,
    orders
from cte2
join menu m
on m.product_id = cte2.product_id
where rnk_order = 1
order by customer_id;

-- 6. Which item was purchased first by the customer after they became a member?

-- using WINDOW FUNCTIONS, CTE, CASE & JOINS
with cte as (
select 
	m.customer_id,
    order_date,
    product_id,
    case when order_date >= join_date then 1 else 0 end as member
from sales as s	
inner join members as m
on m.customer_id = s.customer_id),

cte2 as
(select 
	*,
rank() over(partition by customer_id order by order_date) as rnk_order
from cte
where member = 1)

select
	customer_id,
    product_name
from cte2
join menu 
on menu.product_id = cte2.product_id
where rnk_order = 1
order by customer_id;

-- using WINDOW FUNCTIONS, CTE, JOINS
with cte as (
select
	s.customer_id,
    order_date,
    product_id,
	rank() over(partition by s.customer_id order by order_date) as rnk_order
from sales s
join members m
on s.customer_id = m.customer_id
	and s.order_date >= m.join_date)
    
select 
	customer_id,
    product_name
from cte
join menu
on menu.product_id = cte.product_id
where rnk_order = 1
order by customer_id;

-- 7. Which item was purchased just before the customer became a member?

with cte as (
select 
	s.customer_id,
    order_date,
    product_id,
	rank() over(partition by s.customer_id order by order_date desc) as rnk_order
from sales as s
inner join members as m
on m.customer_id = s.customer_id 
	and s.order_date < m.join_date
order by order_date)

select 
	customer_id,
    product_name
from cte
join menu m
on m.product_id = cte.product_id
where rnk_order = 1
order by customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?

with cte as (
select 
	s.customer_id,
    price
from sales as s
join members as m
on s.customer_id = m.customer_id 
	and s.order_date < m.join_date 
join menu
on  menu.product_id = s.product_id
order by s.customer_id)

select 
	customer_id,
    count(price) as number_of_orders,
    sum(price) as amount_spent
from cte
group by customer_id
order by customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte as (
select
	customer_id,
    product_name,
    price,
    case when product_name = 'sushi' then 20 else 10 end as bonus
from sales
join menu 
on menu.product_id = sales.product_id)

select  
	customer_id,
    sum(price*bonus) as points_earned
from cte
group by customer_id
order by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
	-- how many points do customer A and B have at the end of January?
with membership_status as (
select 
	s.customer_id,
    s.order_date,
    s.product_id,
    m.join_date,
    mn.product_name,
    mn.price,
    case when order_date < join_date then 'not a member' 
		 when order_date between join_date and date_add(join_date, interval 6 day) then 'member and signing bonus'
         else 'member'
         end as membership
from sales s
join members m
on m.customer_id = s.customer_id
join menu mn
on mn.product_id = s.product_id
where order_date <= '2021-01-31'),  -- or month(order_date) = 1

points as (
select 
	*,
    case when membership in ('not a member', 'member') and product_name not like 'sushi' then 10 
		when membership in ('not a member', 'member') and product_name like 'sushi' then 20
        when membership like 'member and signing bonus' then 20 
        end as bonus
from membership_status
order by customer_id, order_date)

select 
	customer_id,
    sum(price * bonus) as points_earned
from points
group by customer_id
order by customer_id;

-- BONUS QUESTION #1

create temporary table tracking
select 
	s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
	case when join_date is null or order_date < join_date then 'N' else 'Y' end as member 
from sales as s
join menu as m
on s.product_id = m.product_id
left join members as mem
on s.customer_id = mem.customer_id
order by s.customer_id, order_date, product_name;

select * from tracking;

-- BONUS QUESTION #2

select *,
	case when member = 'N' then "null" 
    else rank() over(partition by customer_id, member order by order_date) end as ranking
from tracking;







