# Case Study #2: Pizza runner - Runner and Customer Experience

## Case Study Questions

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?

***

###  1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

```sql
SELECT
  FLOOR(
    datediff (registration_date, '2021-01-01') / 7 + 1
  ) week_num,
  COUNT(
    FLOOR(
      datediff (registration_date, '2021-01-01') / 7 + 1
    )
  ) signed_in
FROM
  runners
GROUP BY
  1;
``` 
	
#### Result set:

| week_num | signed_in |
|----------|-----------|
| 1        | 2         |
| 2        | 1         |
| 3        | 1         |

***

###  2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

```sql
SELECT
  ro.runner_id,
  CEIL(
    AVG(
      TIMESTAMPDIFF (MINUTE, co.order_time, ro.pickup_time)
    )
  ) ave_time_to_arrival
FROM
  runner_orders ro
  JOIN customer_orders co ON ro.order_id = co.order_id
WHERE
  ro.cancellation IS NULL
GROUP BY
  1
``` 
	
#### Result set:

| runner_id | ave_time_to_arrival |
|-----------|---------------------|
| 1         | 16                  |
| 2         | 24                  |
| 3         | 10                  |

***
###  3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

```sql
SELECT
  pizza_count,
  ROUND(AVG(time_to_prepare)) time_to_prepare
FROM
  (
    SELECT
      co.order_id,
      COUNT(pizza_id) pizza_count,
      CEIL(
        AVG(
          TIMESTAMPDIFF (MINUTE, co.order_time, ro.pickup_time)
        )
      ) time_to_prepare
    FROM
      runner_orders ro
      JOIN customer_orders co ON ro.order_id = co.order_id
    WHERE
      ro.cancellation IS NULL
    GROUP BY
      1
  ) t
GROUP BY
  1;
``` 
	
#### Result set:

| pizza_count     | time_to_prepare |
|-----------------|-----------------|
| 1               | 12              |
| 2               | 18              |
| 3               | 29              |

- The more pizza in an order, the more time it took to prepare. The correlation is strong but not linear.

***

###  4. What was the average distance travelled for each customer?

```sql
SELECT
  customer_id,
  ROUND(AVG(distance), 2) AS avg_distant
FROM
  customer_orders co
  JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE
  cancellation IS NULL
GROUP BY
  1;
``` 
	
#### Result set:

| customer_id | avg_distance |
|-------------|--------------|
| 101         | 20.00        |
| 102         | 16.73        |
| 103         | 23.40        |
| 104         | 10.00        |
| 105         | 25.00        |

***
###  5. What was the difference between the longest and shortest delivery times for all orders?

```sql
SELECT
  MAX(duration) - MIN(duration) AS time_diff
FROM
  runner_orders
WHERE
  cancellation IS NULL;
``` 
	
#### Result set:

| time_diff |
|-----------|
| 30        |

***
###  6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

```sql
SELECT
  runner_id,
  ROUND(AVG(distance / (duration / 60)), 2) AS avg_speed
FROM
  runner_orders
WHERE
  cancellation IS NULL
GROUP BY
  1;
``` 
	
#### Result set:

| runner_id | avg_speed (km/h) |
|-----------|------------------|
| 1         | 45.54            |
| 2         | 62.90            |
| 3         | 40.00            |

***
###  7. What is the successful delivery percentage for each runner?

```sql
SELECT
  runner_id,
  ROUND(
    SUM(cancellation IS NULL) / COUNT(order_id) * 100,
    0
  ) AS delivery_success_rate
FROM
  runner_orders
GROUP BY
  1;
``` 
	
#### Result set:

| runner_id | delivery_success_rate (%) |
|-----------|---------------------------|
| 1         | 100                       |
| 2         | 75                        |
| 3         | 50                        |

***
