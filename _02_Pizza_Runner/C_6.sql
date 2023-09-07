-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

select
	standard_ingredients,
    count(standard_ingredients) as frequency
from complete
group by standard_ingredients
order by frequency desc;









