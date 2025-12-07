## Case Study #6: Clique Bait - Digital Analysis

Using the available datasets - answer the following questions using a single query for each one:

1. How many users are there?
2. How many cookies does each user have on average?
3. What is the unique number of visits by all users per month?
4. What is the number of events for each event type?
5. What is the percentage of visits which have a purchase event?
6. What is the percentage of visits which view the checkout page but do not have a purchase event?
7. What are the top 3 pages by number of views?
8. What is the number of views and cart adds for each product category?
9. What are the top 3 products by purchases?

### 1. How many users are there?

```sql
SELECT
  COUNT(DISTINCT (user_id)) user_count
FROM
  users;
```

#### Result set:

| user_count |
|----------|
| 500      |

***

### 2. How many cookies does each user have on average?

```sql
SELECT
  ROUND(AVG(cookies_count), 2) avg_cookies
FROM
  (
    SELECT
      user_id,
      COUNT(*) cookies_count
    FROM
      users
    GROUP BY
      1
  ) t;
```

#### Result set:

| avg_cookies |
|-------------|
| 3.56        |

***

### 3. What is the unique number of visits by all users per month?

```sql
SELECT
  MONTH (event_time) AS MONTH,
  COUNT(DISTINCT (visit_id)) unique_visit_count
FROM
  events
GROUP BY
  1
ORDER BY
  1;
```

#### Result set:

| month | unique_visit_count |
|-------|--------------------|
| 1     | 876                |
| 2     | 1488               |
| 3     | 916                |
| 4     | 248                |
| 5     | 36                 |

***

### 4. What is the number of events for each event type?

```sql
SELECT
  event_type,
  COUNT(*) count
FROM
  events
GROUP BY
  1
ORDER BY
  1;
```

#### Result set:

| event_type | count  |
|------------|--------|
| 1          | 20928  |
| 2          | 8451   |
| 3          | 1777   |
| 4          | 876    |
| 5          | 702    |

***

### 5. What is the percentage of visits which have a purchase event?

```sql
-- With event_type 3 is Purchase, we would focus on event_type 3, and even if within a visit, a customer made 2 purchase, we would only count this as 1
SELECT
  all_visit,
  visit_with_purchase,
  ROUND(visit_with_purchase / all_visit * 100, 2) percentage
FROM
  (
    SELECT
      COUNT(DISTINCT (visit_id)) all_visit,
      COUNT(
        DISTINCT CASE
          WHEN event_type = 3 THEN visit_id
        END
      ) visit_with_purchase
    FROM
      events
  ) t;
```

#### Result set:

| all_visit | visit_with_purchase | percentage |
|-----------|---------------------|------------|
| 3564      | 1777                | 49.86      |

***

### 6. What is the percentage of visits which view the checkout page but do not have a purchase event?

```sql
-- We would count visit_id visited page_id = 12 (Checkout) but did not visit page_id = 13 (Confirmation)
WITH
  cte AS (
    SELECT
      visit_id,
      MAX(
        CASE
          WHEN page_id = 12 THEN 1
          ELSE 0
        END
      ) AS checkout,
      MAX(
        CASE
          WHEN page_id = 13 THEN 1
          ELSE 0
        END
      ) AS purchase
    FROM
      events
    GROUP BY
      1
  )
SELECT
  ROUND(
    (SUM(checkout) - SUM(purchase)) / SUM(checkout) * 100,
    2
  ) AS no_purchase_after_checkout_percentage
FROM
  cte;
```

#### Result set:

| no_purchase_after_checkout_percentage |
|---------------------------------------|
| 15.50                                 |

***

### 7. What are the top 3 pages by number of views?

```sql
SELECT
  ph.page_name,
  SUM(
    CASE
      WHEN event_type = 1 THEN 1
    END
  ) page_view
FROM
  events e
  JOIN page_hierarchy ph ON e.page_id = ph.page_id
GROUP BY
  1
ORDER BY
  2 DESC
LIMIT
  3;
```

#### Result set:

| page_name     | page_view |
|---------------|-----------|
| All Products  | 3174      |
| Checkout      | 2103      |
| Home Page     | 1782      |

***

### 8. What is the number of views and cart adds for each product category?

```sql
SELECT DISTINCT
  (product_category),
  SUM(
    CASE
      WHEN event_type = 1 THEN 1
    END
  ) page_views,
  SUM(
    CASE
      WHEN event_type = 2 THEN 1
    END
  ) add_to_cart_count
FROM
  events e
  LEFT JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE
  product_category IS NOT NULL
GROUP BY
  1
ORDER BY
  2 DESC;
```

#### Result set:

| product_category | page_views | add_to_cart_count |
|------------------|------------|-------------------|
| Shellfish        | 6204       | 3792              |
| Fish             | 4633       | 2789              |
| Luxury           | 3032       | 1870              |

***

### 9. What are the top 3 products by purchases?

```sql
-- I would assume the cart is not shared between cookie_id of the same user
-- So a product is counted as purchased when with in a cookie_id, that product was added to cart, then there was as purchase event after
WITH
  atc AS (
    SELECT
      cookie_id,
      page_id,
      event_time
    FROM
      events
    WHERE
      event_type = 2
  ),
  pc AS (
    SELECT
      cookie_id,
      page_id,
      event_time
    FROM
      events
    WHERE
      event_type = 3
  ),
  combine AS (
    SELECT DISTINCT
      (atc.event_time),
      atc.cookie_id,
      atc.page_id
    FROM
      atc
      INNER JOIN pc ON atc.cookie_id = pc.cookie_id
    WHERE
      pc.event_time > atc.event_time
  ) -- to weed out the case that a product was added to cart after a purchase 
SELECT
  ph.page_name product_name,
  COUNT(*) purchase_count
FROM
  combine c
  JOIN page_hierarchy ph ON c.page_id = ph.page_id
GROUP BY
  1
ORDER BY
  2 DESC
LIMIT
  3
```

#### Result set:

| product_name | purchase_count |
|--------------|----------------|
| Lobster      | 793            |
| Oyster       | 771            |
| Crab         | 770            |

***