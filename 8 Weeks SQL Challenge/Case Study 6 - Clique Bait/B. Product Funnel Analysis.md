## Case Study #6: Clique Bait - Product Funnel Analysis

Using a single SQL query - create a new output table which has the following details:
- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?

```sql
-- For question 3 and 4, i would also do them on cookie_id basis
WITH
  p AS ( -- get time_stamp of last purchase in a cookie_id
    SELECT
      cookie_id cid,
      MAX(event_time) pt
    FROM
      events
    WHERE
      event_type = 3
    GROUP BY
      1
  ),
  ac AS ( -- set the list of all add_to_cart event
    SELECT
      cookie_id cid,
      page_id pid,
      event_time et
    FROM
      events
    WHERE
      event_type = 2
  ),
  acc AS ( -- get the add_to_cart count per page_id
    SELECT
      pid,
      COUNT(*) cart_add
    FROM
      ac
    GROUP BY
      1
  ),
  vc AS ( -- get the pageview count per page_id
    SELECT
      pid,
      COUNT(*) views
    FROM
      (
        SELECT
          cookie_id cid,
          page_id pid,
          event_time et
        FROM
          events
        WHERE
          event_type = 1
      ) t
    GROUP BY
      1
  ),
  cb AS ( -- combine both p and ac for later querries
    SELECT
      ac.*,
      pt
    FROM
      ac
      LEFT JOIN p ON ac.cid = p.cid
  ),
  apc AS ( -- get product added then purchased
    SELECT
      pid,
      COUNT(*) purchased
    FROM
      cb
    WHERE
      et < pt
    GROUP BY
      1
  ),
  ab AS ( -- get product added but abandoned
    SELECT
      pid,
      COUNT(*) abandoned
    FROM
      cb
    WHERE
      pt IS NULL
    GROUP BY
      1
  )
SELECT
  ph.page_name,
  views,
  cart_add,
  purchased,
  abandoned
FROM
  acc
  JOIN vc ON acc.pid = vc.pid
  JOIN apc ON acc.pid = apc.pid
  JOIN ab ON acc.pid = ab.pid
  JOIN page_hierarchy ph ON acc.pid = ph.page_id
ORDER BY
  acc.pid;
```
#### Result set:

| page_name       | views | cart_add | purchased | abandoned |
|-----------------|-------|----------|-----------|-----------|
| Salmon          | 1559  | 938      | 763       | 130       |
| Kingfish        | 1559  | 920      | 753       | 117       |
| Tuna            | 1515  | 931      | 756       | 127       |
| Russian Caviar  | 1563  | 946      | 758       | 142       |
| Black Truffle   | 1469  | 924      | 748       | 112       |
| Abalone         | 1525  | 932      | 746       | 129       |
| Lobster         | 1547  | 968      | 793       | 126       |
| Crab            | 1564  | 949      | 770       | 130       |
| Oyster          | 1568  | 943      | 771       | 121       |

***

- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

> This could be done by simply change the final query from page_name to product_category and sum other metric

```sql
SELECT
  ph.product_category,
  SUM(views),
  SUM(cart_add),
  SUM(purchased),
  SUM(abandoned)
FROM
  acc
  JOIN vc ON acc.pid = vc.pid
  JOIN apc ON acc.pid = apc.pid
  JOIN ab ON acc.pid = ab.pid
  JOIN page_hierarchy ph ON acc.pid = ph.page_id
GROUP BY
  1
ORDER BY
  1;
```
#### Result set:

| product_category | sum(views) | sum(cart_add) | sum(purchased) | sum(abandoned) |
|------------------|------------|---------------|----------------|----------------|
| Fish             | 4633       | 2789          | 2272           | 374            |
| Luxury           | 3032       | 1870          | 1506           | 254            |
| Shellfish        | 6204       | 3792          | 3080           | 506            |

***

Use your 2 new output tables - answer the following questions:
    Which product had the most views, cart adds and purchases?
    Which product was most likely to be abandoned?
    Which product had the highest view to purchase percentage?
    What is the average conversion rate from view to cart add?
    What is the average conversion rate from cart add to purchase?

- I adjusted the previous query and add the 'final' cte to save time:

```sql
final AS (
  SELECT
    ph.page_name product,
    views,
    cart_add,
    purchased,
    abandoned
  FROM
    acc
    JOIN vc ON acc.pid = vc.pid
    JOIN apc ON acc.pid = apc.pid
    JOIN ab ON acc.pid = ab.pid
    JOIN page_hierarchy ph ON acc.pid = ph.page_id
)
```

- Which product had the most views, cart adds and purchases?
> Lobster had the most cart_add and purchased
> Oyster had the most views

- Which product was most likely to be abandoned?

```sql
SELECT
  product,
  ROUND(abandoned / cart_add * 100, 2) abandoned_rate
FROM
  final
ORDER BY
  2 DESC
LIMIT
  1;
```

#### Result set:

| product        | abandoned_rate |
|----------------|----------------|
| Russian Caviar | 15.01          |

> The product was most likely to be abandoned is Russian Caviar at 15.01% abandoned rate

***

- Which product had the highest view to purchase percentage?

```sql
SELECT
  product,
  ROUND(purchased / views * 100, 2) view_purchase_ratio
FROM
  final
ORDER BY
  2 DESC
LIMIT
  1;
```

#### Result set:

| product | view_purchase_ratio |
|---------|---------------------|
| Lobster | 51.26               |

> The product had the highest view to purchase percentage is Lobster at 51.26%

***

> What is the average conversion rate from view to cart add?

```sql
SELECT
  ROUND(SUM(cart_add) / SUM(views) * 100, 2) conversion_rate
FROM
  final;
```
#### Result set:

| conversion_rate |
|-----------------|
| 60.93           |
- The conversion rate was 60.93%

***

- What is the average conversion rate from cart add to purchase?

```sql
SELECT
  ROUND(SUM(purchased) / SUM(cart_add) * 100, 2) conversion_rate
FROM
  final;
```

#### Result set:

| conversion_rate |
|-----------------|
| 81.15           |

> The conversion rate was 81.15%

***