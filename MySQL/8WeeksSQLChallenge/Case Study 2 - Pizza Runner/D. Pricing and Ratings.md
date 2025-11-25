# Case Study #2: Pizza runner - Pricing and Ratings

## Case Study Questions

1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
- customer_id
- order_id
- runner_id
- rating
- order_time
- pickup_time
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

***

###  1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

```sql
SELECT
  SUM(
    CASE
      WHEN pizza_id = 1 THEN 12
      ELSE 10
    END
  ) AS revenue
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
  );
``` 
	
#### Result set:

| revenue |
|--------:|
| 138     |

***

###  2.What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra

```sql
SELECT
  SUM(
    CASE
      WHEN pizza_id = 1 THEN 12
      ELSE 10
    END + extras
  ) AS total_revenue_with_extras
FROM
  (
    SELECT
      pizza_number,
      pizza_id,
      COUNT(DISTINCT (extras)) extras
    FROM
      orders_sorted co
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
      1,
      2
  ) t;
``` 
	
#### Result set:

| total_revenue_with_extras |
|---------------------------|
| 142                       |

- Add cheese is $1 extra

```sql
SELECT
  SUM(
    (
      CASE
        WHEN pizza_id = 1 THEN 12
        ELSE 10
      END
    ) / (
      CASE
        WHEN dup > 1 THEN dup
        ELSE 1
      END
    ) + CASE
      WHEN extras = 4 THEN 2
      WHEN extras IS NULL THEN 0
      ELSE 1
    END
  ) AS revenue
FROM
  (
    SELECT
      pizza_number,
      pizza_id,
      extras,
      COUNT(extras) AS dup
    FROM
      orders_sorted co
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
      1,
      2,
      3
  ) t;
```
#### Result set:

| total_revenue_with_extras |
|---------------------------|
| 143                       |

***
###  3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

```sql
create table runner_rating (order_id integer, rating integer, review varchar(100)) ;

-- Order 6 and 9 were cancelled
insert into runner_rating
values ('1', '1', 'Really bad service'),
       ('2', '1', null),
       ('3', '4', 'Took too long...'),
       ('4', '1','Runner was lost, delivered it AFTER an hour. Pizza arrived cold' ),
       ('5', '2', 'Good service'),
       ('7', '5', 'It was great, good service and fast'),
       ('8', '2', 'He tossed it on the doorstep, poor service'),
       ('10', '5', 'Delicious!, he delivered it sooner than expected too!');
``` 
	
#### Result set:

| order_id | rating | review                                              |
|---------:|-------:|-----------------------------------------------------|
| 1        | 1      | Really bad service                                  |
| 2        | 1      |                                                     |
| 3        | 4      | Took too long...                                    |
| 4        | 1      | Runner was lost, delivered it AFTER an hour. Pizza arrived cold |
| 5        | 2      | Good service                                        |
| 7        | 5      | It was great, good service and fast                 |
| 8        | 2      | He tossed it on the doorstep, poor service         |
| 10       | 5      | Delicious!, he delivered it sooner than expected too! |

***

###  4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
- customer_id
- order_id
- runner_id
- rating
- order_time
- pickup_time
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas

```sql
CREATE TABLE order_all AS
SELECT DISTINCT
  (co.order_id),
  co.customer_id,
  ro.runner_id,
  rr.rating,
  co.order_time,
  ro.pickup_time,
  TIMESTAMPDIFF (MINUTE, co.order_time, ro.pickup_time) till_pick_up,
  ro.duration delivery_duration,
  ROUND(ro.distance / ro.duration * 60) AS avg_speed,
  t.pizza_count
FROM
  orders_sorted co
  LEFT JOIN runner_orders ro ON ro.order_id = co.order_id
  LEFT JOIN runner_rating rr ON rr.order_id = co.order_id
  LEFT JOIN (
    SELECT
      order_id,
      COUNT(pizza_id) pizza_count
    FROM
      customer_orders
    GROUP BY
      1
  ) t ON t.order_id = co.order_id
WHERE
  co.order_id NOT IN (
    SELECT
      ro.order_id
    FROM
      runner_orders ro
    WHERE
      ro.cancellation IS NOT NULL
  );
``` 
	
#### Result set:

| order_id | customer_id | runner_id | rating | order_time           | pickup_time          | till_pick_up | delivery_duration | avg_speed | pizza_count |
|---------:|------------:|----------:|-------:|----------------------|----------------------|-------------:|------------------:|----------:|------------:|
| 1        | 101         | 1         | 1      | 2020-01-01 18:05:02  | 2020-01-01 18:15:34  | 10           | 32                | 38        | 1           |
| 2        | 101         | 1         | 1      | 2020-01-01 19:00:52  | 2020-01-01 19:10:54  | 10           | 27                | 44        | 1           |
| 3        | 102         | 1         | 4      | 2020-01-02 23:51:23  | 2020-01-03 00:12:37  | 21           | 20                | 40        | 2           |
| 4        | 103         | 2         | 1      | 2020-01-04 13:23:46  | 2020-01-04 13:53:03  | 29           | 40                | 35        | 3           |
| 5        | 104         | 3         | 2      | 2020-01-08 21:00:29  | 2020-01-08 21:10:57  | 10           | 15                | 40        | 1           |
| 7        | 105         | 2         | 5      | 2020-01-08 21:20:29  | 2020-01-08 21:30:45  | 10           | 25                | 60        | 1           |
| 8        | 102         | 2         | 2      | 2020-01-09 23:54:33  | 2020-01-10 00:15:02  | 20           | 15                | 94        | 1           |
| 10       | 104         | 1         | 5      | 2020-01-11 18:34:49  | 2020-01-11 18:50:20  | 15           | 10                | 60        | 2           |

***

###   5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometer traveled - how much money does Pizza Runner have left over after these deliveries?

```sql
SELECT
  ROUND(SUM(pizza_price - delivery_fee), 2) AS left_over
FROM
  (
    SELECT
      co.order_id,
      SUM(
        CASE
          WHEN pizza_id = 1 THEN 12
          ELSE 10
        END
      ) pizza_price,
      SUM(DISTINCT (ROUND(ro.distance * 0.3, 2))) AS delivery_fee
    FROM
      customer_orders co
      JOIN runner_orders ro ON co.order_id = ro.order_id
    WHERE
      co.order_id NOT IN (
        SELECT
          ro.order_id
        FROM
          runner_orders ro
        WHERE
          ro.cancellation IS NOT NULL
      )
    GROUP BY
      1
  ) t;
``` 
	
#### Result set:

| left_over |
|----------:|
| 94.44     |

***