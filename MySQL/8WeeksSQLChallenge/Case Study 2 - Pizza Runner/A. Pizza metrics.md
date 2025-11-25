# Case Study #2: Pizza runner - Pizza Metrics

## Case Study Questions

1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

***

###  1. How many pizzas were ordered?

```sql
SELECT
  COUNT(pizza_id) pizza_ordered
FROM
  customer_orders;
```

#### Result set:

| pizza_ordered |
|---------------|
| 14            |

***

###  2. How many unique customer orders were made?

```sql
SELECT
  COUNT(DISTINCT (order_id)) unique_order
FROM
  customer_orders;
```

#### Result set:

| unique_orders |
|---------------|
| 10            |

***

###  3. How many successful orders were delivered by each runner?

```sql
SELECT
  runner_id,
  COUNT(DISTINCT (order_id)) order_count
FROM
  runner_orders
WHERE
  cancellation IS NULL
GROUP BY
  1;
```

#### Result set:

| runner_id | order_count |
|-----------|-------------|
| 1         | 4           |
| 2         | 3           |
| 3         | 1           |

***

###  4. How many of each type of pizza was delivered?

```sql
SELECT
  pizza_id,
  COUNT(order_id) AS pizza_count
FROM
  customer_orders co
WHERE
  order_id NOT IN (
    SELECT
      ro.order_id
    FROM
      runner_orders ro
    WHERE
      ro.cancellation IS NOT NULL
  )
GROUP BY
  pizza_id;
```

#### Result set:

| pizza_id | pizza_count |
|----------|-------------|
| 1        | 9           |
| 2        | 3           |

***

###  5. How many Vegetarian and Meatlovers were ordered by each customer?

```sql
SELECT
  customer_id,
  pizza_id,
  COUNT(pizza_id) pizza_count
FROM
  customer_orders
GROUP BY
  1,
  2;
```

#### Result set:

| customer_id | pizza_id | pizza_count |
|-------------|----------|-------------|
| 101         | 1        | 2           |
| 102         | 1        | 2           |
| 102         | 2        | 1           |
| 103         | 1        | 3           |
| 103         | 2        | 1           |
| 104         | 1        | 3           |
| 101         | 2        | 1           |
| 105         | 2        | 1           |

***

###  6. What was the maximum number of pizzas delivered in a single order?

```sql
SELECT
  MAX(t.pc) AS max_pizza_on_1_order
FROM
  runner_orders ro
  JOIN (
    SELECT
      order_id,
      COUNT(pizza_id) pc
    FROM
      customer_orders
    GROUP BY
      1
  ) t ON ro.order_id = t.order_id
WHERE
  ro.cancellation IS NULL;
```

#### Result set:

| max_pizza_on_1_order |
|----------------------|
| 3                    |

***

###  7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

```sql
SELECT
  customer_id,
  SUM(
    CASE
      WHEN exclusions IS NULL
      AND extras IS NULL THEN 1
      ELSE 0
    END
  ) AS no_change,
  SUM(
    CASE
      WHEN exclusions IS NOT NULL
      OR extras IS NOT NULL THEN 1
      ELSE 0
    END
  ) AS changed
FROM
  customer_orders
WHERE
  order_id NOT IN (
    SELECT
      ro.order_id
    FROM
      runner_orders ro
    WHERE
      ro.cancellation IS NOT NULL
  )
GROUP BY
  1;
```

#### Result set:

| customer_id | no_change | changed |
|-------------|-----------|---------|
| 101         | 2         | 0       |
| 102         | 3         | 0       |
| 103         | 0         | 3       |
| 104         | 1         | 2       |
| 105         | 0         | 1       |

***

###  8. How many pizzas were delivered that had both exclusions and extras?

```sql
SELECT
  SUM(
    CASE
      WHEN exclusions IS NOT NULL
      AND extras IS NOT NULL THEN 1
      ELSE 0
    END
  ) AS exclu_and_extra
FROM
  customer_orders
WHERE
  order_id NOT IN (
    SELECT
      ro.order_id
    FROM
      runner_orders ro
    WHERE
      ro.cancellation IS NOT NULL
  );
```

#### Result set:

| exclu_and_extra |
|-----------------|
| 1               |

***

###  9. What was the total volume of pizzas ordered for each hour of the day?

```sql
SELECT DISTINCT
  (HOUR (order_time)) hour_of_the_date,
  COUNT(order_time) order_count
FROM
  customer_orders
GROUP BY
  1
ORDER BY
  1;
```

#### Result set:

| hour_of_the_day | order_count |
|-----------------|-------------|
| 11              | 1           |
| 13              | 3           |
| 18              | 3           |
| 19              | 1           |
| 21              | 3           |
| 23              | 3           |

***

###  10. What was the volume of orders for each day of the week?

```sql
SELECT DISTINCT
  (dayofweek (order_time)) day_of_week,
  COUNT(order_time) order_count
FROM
  customer_orders
GROUP BY
  1
ORDER BY
  1;
```

#### Result set:

| day_of_week | order_count |
|-------------|-------------|
| 4           | 5           |
| 5           | 3           |
| 6           | 1           |
| 7           | 5           |

***
