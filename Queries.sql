-- A. Pizza Metrics

SELECT 
    COUNT(*)
FROM
    customer_orders;

-- How many unique customer orders were made?
SELECT 
    COUNT(DISTINCT order_id)
FROM
    customer_orders;

-- How many successful orders were delivered by each runner?
SELECT 
    runner_id, COUNT(order_id)
FROM
    runner_orders
WHERE
    distance != 0
GROUP BY runner_id;


-- How many of each type of pizza was delivered?
SELECT 
    p.pizza_name, COUNT(c.order_id)
FROM
    pizza_names p
        JOIN
    customer_orders c ON p.pizza_id = c.pizza_id
        JOIN
    runner_orders r ON c.order_id = r.order_id
WHERE
    r.distance != 0
GROUP BY p.pizza_name;


-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
    c.customer_id, p.pizza_name, COUNT(p.pizza_name)
FROM
    pizza_names p
        JOIN
    customer_orders c ON p.pizza_id = c.pizza_id
GROUP BY c.customer_id , p.pizza_name
ORDER BY c.customer_id;


-- What was the maximum number of pizzas delivered in a single order?
SELECT 
    order_id, COUNT(pizza_id)
FROM
    customer_orders
GROUP BY order_id
ORDER BY COUNT(pizza_id) DESC
LIMIT 1;


-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
    c.customer_id,
    SUM(CASE
        WHEN c.exclusions <> ' ' OR c.extras <> ' ' THEN 1
        ELSE 0
    END) AS at_least_1_change,
    SUM(CASE
        WHEN c.exclusions = ' ' AND c.extras = ' ' THEN 1
        ELSE 0
    END) AS no_change
FROM
    customer_orders AS c
        JOIN
    runner_orders AS r ON c.order_id = r.order_id
WHERE
    r.distance != 0
GROUP BY c.customer_id
ORDER BY c.customer_id;


-- How many pizzas were delivered that had both exclusions and extras?
SELECT 
    SUM(CASE
        WHEN
            exclusions IS NOT NULL
                AND extras IS NOT NULL
        THEN
            1
        ELSE 0
    END) AS pizza_count_w_exclusions_extras
FROM
    customer_orders AS c
        JOIN
    runner_orders AS r ON c.order_id = r.order_id
WHERE
    r.distance >= 1 AND exclusions <> ' '
        AND extras <> ' ';


-- What was the total volume of pizzas ordered for each hour of the day?
SELECT 
    HOUR(order_date) AS hour_of_day,
    COUNT(order_id) AS pizza_count
FROM
    customer_orders
GROUP BY HOUR(order_date);



-- What was the volume of orders for each day of the week?
SELECT FORMAT(DATEADD(DAY, 2, order_time),'dddd') AS day_of_week, 
 COUNT(order_id) AS total_pizzas_ordered
FROM #customer_orders
GROUP BY FORMAT(DATEADD(DAY, 2, order_time),'dddd');


-- B. Runner and Customer Experience

SELECT 
    WEEK(registration_date) AS weekwise, COUNT(runner_id)
FROM
    runners
GROUP BY WEEK(registration_date);

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH time_taken_cte AS
(
 SELECT c.order_id, c.order_time, r.pickup_time, 
  DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS pickup_minutes
 FROM customer_orders AS c
 JOIN runner_orders AS r
  ON c.order_id = r.order_id
 WHERE r.distance != 0
 GROUP BY c.order_id, c.order_time, r.pickup_time
)
SELECT AVG(pickup_minutes) AS avg_pickup_minutes
FROM time_taken_cte
WHERE pickup_minutes > 1;


-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH prep_time_cte AS
(
 SELECT c.order_id, COUNT(c.order_id) AS pizza_order, 
  c.order_time, r.pickup_time, 
  DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time_minutes
 FROM customer_orders AS c
 JOIN runner_orders AS r
  ON c.order_id = r.order_id
 WHERE r.distance != 0
 GROUP BY c.order_id, c.order_time, r.pickup_time
)
SELECT pizza_order, AVG(prep_time_minutes) AS avg_prep_time_minutes
FROM prep_time_cte
WHERE prep_time_minutes > 1
GROUP BY pizza_order;


-- What was the average distance travelled for each customer?\
SELECT 
    c.customer_id, AVG(r.distance) AS avg_distance
FROM
    customer_orders c
        JOIN
    runner_orders r ON c.order_id = r.order_id
WHERE
    r.duration != 0
GROUP BY c.customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT 
    MAX(duration) - MIN(duration)
FROM
    runner_orders
WHERE
    duration NOT LIKE ' ';


-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
    c.customer_id,
    r.runner_id,
    r.order_id,
    COUNT(c.order_id) AS Pizza_count,
    r.distance,
    ROUND((r.duration / 60), 2) AS Duration_hr,
    ROUND((r.distance / r.duration * 60), 2) AS avg_speed
FROM
    customer_orders c
        JOIN
    runner_orders r ON c.order_id = r.order_id
WHERE
    r.distance != 0
GROUP BY r.runner_id , c.customer_id , c.order_id , r.distance
ORDER BY c.order_id;


-- What is the successful delivery percentage for each runner?

SELECT 
    runner_id,
    ROUND(100 * SUM(CASE
                        WHEN distance = 0 THEN 0
                        ELSE 1
                    END) / COUNT(*),
            0) AS success_perc
FROM
    runner_orders
GROUP BY runner_id;






