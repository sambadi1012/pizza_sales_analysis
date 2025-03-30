-- Retrieve the total number of orders placed
SELECT
	COUNT(order_id) AS Total_Order_Placed
FROM
	orders;

-- Calculate the total revenue generated from pizza sales.
SELECT
	ROUND(SUM(orders_details.quantity* pizzas.price),
			2) AS Total_Revenue
FROM
	orders_details
JOIN
	pizzas ON orders_details.pizza_id = pizzas.pizza_id;
    
-- Identify the highest-priced pizza.
SELECT
	pizza_types.name, pizzas.price
FROM
	pizza_types
JOIN
	pizzas ON pizza_types.pizza_type_id= pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT
	pizzas.size, COUNT(orders_details.quantity) AS Order_count
FROM
	orders_details
JOIN
	pizzas ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT
	pizza_types.name AS Pizza_Name,
	SUM(orders_details.quantity) AS Quantity
FROM
	pizza_types
JOIN
	pizzas ON pizza_types.pizza_type_id= pizzas.pizza_type_id
JOIN
	orders details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT
	pizza_types.category,
	SUM(orders_details.quantity) AS quantity
FROM
	pizza_types
JOIN
	pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN
	orders details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT
	HOUR(order_time) AS Hour, COUNT(order_id) AS Order_count
FROM
	orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT
	category, COUNT(name) AS no_of_pizza
FROM
	pizza_types
GROUP BY category
ORDER BY no_of_pizza DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT
	ROUND(AVG(Quantity_orderd), 0) Average_orders_per_day
FROM
	(SELECT
		orders.order_date,
			SUM(orders_details.quantity) AS Quantity_orderd
	FROM
		orders
	JOIN orders_details ON orders.order_id = orders_details.order_id
	GROUP BY orders.order_date) AS order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT
	pizza_types.name,
	SUM(orders_details.quantity * pizzas.price) AS Revenue
FROM
	pizzas
JOIN
	pizza types ON pizzas.pirga_type_id = pizza_types.pizza_type_id
JOIN
	orders details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT
	pizza_types.category,
	ROUND((SUM(orders_details.quantity * pizzas.price) / (SELECT
					ROUND(SUM(orders_details.quantity * pizzas.price),
								2) AS Total_Revenue
				FROM
					Worders_details
				JOIN
					pizzas ON orders_details.pizza_id = pizzas.pizza_id)) * 100) AS 'Revenue(%)'

FROM
	pizzas
JOIN
	pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN
	orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;

-- Analyze the cumulative revenue generated over time.

SELECT 
	order_date,
	sum(revenue) OVER(ORDER BY order_date) AS cum_rev
FROM
	(SELECT orders.order_date,
		SUM(orders_details.quantity = pizzas.price) AS Revenue
	FROM
		pizzas
	JOIN
		orders_details ON orders_details.pizza_id = pizzas.pizza_id
	JOIN
		orders ON orders_details.order_id = orders.order_id
	GROUP BY orders.order_date) AS Sales;
    
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, rn from
(
    select category, name, revenue, 
           rank() over(partition by category order by revenue desc) as rn
    from
    (
        select 
            pizza_types.category, pizza_types.name, 
            sum(orders_details.quantity * pizzas.price) as Revenue
        from pizzas
        join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
        join orders_details on orders_details.pizza_id = pizzas.pizza_id
        group by pizza_types.category, pizza_types.name
    ) as a
) as b
where rn <= 3;
