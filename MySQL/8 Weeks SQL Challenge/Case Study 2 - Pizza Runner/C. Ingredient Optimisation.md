# Case Study #2: Pizza runner - Ingredient Optimisation WIP

## Case Study Questions

1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

***

###  1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

```sql
SELECT
  rs.pizza_id,
  group_concat (pt.topping_name separator ', ') AS ingredient
FROM
  recipe_sorted rs
  JOIN pizza_toppings pt ON rs.topping = pt.topping_id
GROUP BY
  1;
``` 
	
#### Result set:

| pizza_id | ingredients                                      |
|----------|--------------------------------------------------|
| 1        | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| 2        | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce           |

***

###  2. What was the most commonly added extra?

```sql
SELECT
  topping_name AS most_added_extra
FROM
  (
    SELECT
      extras,
      COUNT(DISTINCT (pizza_number)) AS ordered,
      DENSE_RANK() OVER (
        ORDER BY
          COUNT(*) DESC
      ) AS ranked
    FROM
      orders_sorted
    WHERE
      extras IS NOT NULL
    GROUP BY
      extras
  ) t
  JOIN pizza_toppings pt ON pt.topping_id = t.extras
WHERE
  ranked = 1;
``` 
	
#### Result set:

| most_added_extra |
|------------------|
| Bacon            |

***

###  3. What was the most common exclusion?

```sql
SELECT
  topping_name AS most_excluded
FROM
  (
    SELECT
      exclusions,
      COUNT(DISTINCT (pizza_number)) AS ordered,
      DENSE_RANK() OVER (
        ORDER BY
          COUNT(*) DESC
      ) AS ranked
    FROM
      orders_sorted
    WHERE
      exclusions IS NOT NULL
    GROUP BY
      exclusions
  ) t
  JOIN pizza_toppings pt ON pt.topping_id = t.exclusions
WHERE
  ranked = 1;
``` 
	
#### Result set:

| most_excluded |
|---------------|
| Cheese        |

***

###  4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

```sql
SELECT
  order_id,
  CASE
    WHEN exclude IS NULL
    AND extra IS NOT NULL THEN CONCAT(pizza_name, ' - Extra: ', extra)
    WHEN extra IS NULL
    AND exclude IS NOT NULL THEN CONCAT(pizza_name, ' - Exclude: ', exclude)
    WHEN exclude IS NULL
    AND extra IS NULL THEN pizza_name
    ELSE CONCAT(
      pizza_name,
      ' - Exclude: ',
      exclude,
      ' - Extra: ',
      extra
    )
  END AS order_item
FROM
  (
    SELECT
      order_id,
      pizza_number,
      pizza_name,
      group_concat (DISTINCT (exclus) separator ', ') AS exclude,
      group_concat (DISTINCT (extras) separator ', ') AS extra
    FROM
      (
        SELECT
          order_id,
          pizza_number,
          pizza_id,
          t1.topping_name AS exclus,
          pt.topping_name AS extras
        FROM
          (
            SELECT
              *
            FROM
              orders_sorted
              LEFT JOIN pizza_toppings ON exclusions = topping_id
          ) t1
          LEFT JOIN pizza_toppings pt ON t1.extras = pt.topping_id
      ) t2
      LEFT JOIN pizza_names pn ON pn.pizza_id = t2.pizza_id
    GROUP BY
      1,
      2,
      3
  ) t3;
``` 
	
#### Result set:

| order_id | order_item                                              |
|---------:|---------------------------------------------------------|
| 1       | Meatlovers                                              |
| 2       | Meatlovers                                              |
| 3       | Meatlovers                                              |
| 3       | Vegetarian                                              |
| 4       | Meatlovers - Exclude: Cheese                            |
| 4       | Meatlovers - Exclude: Cheese                            |
| 4       | Vegetarian - Exclude: Cheese                            |
| 5       | Meatlovers - Extra: Bacon                               |
| 6       | Vegetarian                                              |
| 7       | Vegetarian - Extra: Bacon                               |
| 8       | Meatlovers                                              |
| 9       | Meatlovers - Exclude: Cheese - Extra: Bacon, Chicken    |
| 10      | Meatlovers                                              |
| 10      | Meatlovers - Exclude: BBQ Sauce, Mushrooms - Extra: Bacon, Cheese |

***

###  5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

```sql

``` 
	
#### Result set:



***

###  6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

```sql

``` 
	
#### Result set:



***