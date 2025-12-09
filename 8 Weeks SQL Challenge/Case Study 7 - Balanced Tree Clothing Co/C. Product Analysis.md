## Case Study #7: Balanced Tree Clothing Co. - Product Analysis

1. What are the top 3 products by total revenue before discount?
2. What is the total quantity, revenue and discount for each segment?
3. What is the top selling product for each segment?
4. What is the total quantity, revenue and discount for each category?
5. What is the top selling product for each category?
6. What is the percentage split of revenue by product for each segment?
7. What is the percentage split of revenue by segment for each category?
8. What is the percentage split of total revenue by category?
9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

### 1. What are the top 3 products by total revenue before discount?

```sql
SELECT
  product_name,
  SUM(qty * s.price) revenue
FROM
  sales s
  JOIN product_details pd ON s.prod_id = pd.product_id
GROUP BY
  1
ORDER BY
  2 DESC
LIMIT
  3;
```

#### Result set:

| product_name                 | revenue |
|------------------------------|---------|
| Blue Polo Shirt - Mens       | 217683  |
| Grey Fashion Jacket - Womens | 209304  |
| White Tee Shirt - Mens       | 152000  |

***

### 2. What is the total quantity, revenue and discount for each segment?

```sql
SELECT
  segment_name,
  SUM(qty) total_quantity,
  SUM(qty * s.price) total_raw_revenue,
  ROUND(SUM(qty * s.price * (1 - discount / 100)), 2) total_discounted
FROM
  sales s
  JOIN product_details pd ON s.prod_id = pd.product_id
GROUP BY
  1;
```

#### Result set:

| segment_name | total_quantity | total_raw_revenue | total_discounted |
|--------------|----------------|-------------------|------------------|
| Jeans        | 11349          | 208350            | 183006.03        |
| Shirt        | 11265          | 406143            | 356548.73        |
| Socks        | 11217          | 307977            | 270963.56        |
| Jacket       | 11385          | 366983            | 322705.54        |

***

### 3. What is the top selling product for each segment?

```sql
-- I'll rank the product by raw revenue for this question
WITH
  rn AS (
    SELECT
      segment_name,
      product_name,
      SUM(qty * s.price) total_raw_revenue,
      RANK() OVER (
        PARTITION BY
          segment_name
        ORDER BY
          SUM(qty * s.price) DESC
      ) rnk
    FROM
      sales s
      JOIN product_details pd ON s.prod_id = pd.product_id
    GROUP BY
      1,
      2
  )
SELECT
  segment_name,
  product_name,
  total_raw_revenue
FROM
  rn
WHERE
  rnk = 1;
```

#### Result set:

| segment_name | product_name                     | total_raw_revenue |
|--------------|----------------------------------|-------------------|
| Jacket       | Grey Fashion Jacket - Womens     | 209304            |
| Jeans        | Black Straight Jeans - Womens    | 121152            |
| Shirt        | Blue Polo Shirt - Mens           | 217683            |
| Socks        | Navy Solid Socks - Mens          | 136512            |

***

### 4. What is the total quantity, revenue and discount for each category?

```sql
SELECT
  category_name,
  SUM(qty) total_quantity,
  SUM(qty * s.price) total_raw_revenue,
  ROUND(SUM(qty * s.price * (1 - discount / 100)), 2) total_discounted
FROM
  sales s
  JOIN product_details pd ON s.prod_id = pd.product_id
GROUP BY
  1;
```

#### Result set:

| category_name | total_quantity | total_raw_revenue | total_discounted |
|---------------|----------------|-------------------|------------------|
| Womens        | 22734          | 575333            | 505711.57        |
| Mens          | 22482          | 714120            | 627512.29        |

***

### 5. What is the top selling product for each category?

```sql
-- I'll rank the product by raw revenue for this question
WITH
  rn AS (
    SELECT
      category_name,
      product_name,
      SUM(qty * s.price) total_raw_revenue,
      RANK() OVER (
        PARTITION BY
          category_name
        ORDER BY
          SUM(qty * s.price) DESC
      ) rnk
    FROM
      sales s
      JOIN product_details pd ON s.prod_id = pd.product_id
    GROUP BY
      1,
      2
  )
SELECT
  category_name,
  product_name,
  total_raw_revenue
FROM
  rn
WHERE
  rnk = 1;
```

#### Result set:

| category_name | product_name                 | total_raw_revenue |
|---------------|------------------------------|-------------------|
| Mens          | Blue Polo Shirt - Mens       | 217683            |
| Womens        | Grey Fashion Jacket - Womens | 209304            |

***

### 6. What is the percentage split of revenue by product for each segment?

```sql
WITH
  raw_revenue AS (
    SELECT
      segment_name,
      product_name,
      SUM(qty * s.price) total_raw_revenue
    FROM
      sales s
      JOIN product_details pd ON s.prod_id = pd.product_id
    GROUP BY
      1,
      2
  )
SELECT
  segment_name,
  product_name,
  ROUND(
    total_raw_revenue / SUM(total_raw_revenue) OVER (
      PARTITION BY
        segment_name
    ) * 100,
    2
  ) percentage_split
FROM
  raw_revenue;
```

#### Result set:

| segment_name | product_name                     | percentage_split |
|--------------|----------------------------------|------------------|
| Jacket       | Indigo Rain Jacket - Womens      | 19.45            |
| Jacket       | Khaki Suit Jacket - Womens       | 23.51            |
| Jacket       | Grey Fashion Jacket - Womens     | 57.03            |
| Jeans        | Navy Oversized Jeans - Womens    | 24.06            |
| Jeans        | Cream Relaxed Jeans - Womens     | 17.79            |
| Jeans        | Black Straight Jeans - Womens    | 58.15            |
| Shirt        | White Tee Shirt - Mens           | 37.43            |
| Shirt        | Blue Polo Shirt - Mens           | 53.60            |
| Shirt        | Teal Button Up Shirt - Mens      | 8.98             |
| Socks        | White Striped Socks - Mens       | 20.18            |
| Socks        | Pink Fluro Polkadot Socks - Mens | 35.50            |
| Socks        | Navy Solid Socks - Mens          | 44.33            |

***

### 7. What is the percentage split of revenue by segment for each category?

```sql
WITH
  raw_revenue AS (
    SELECT
      category_name,
      segment_name,
      SUM(qty * s.price) total_raw_revenue
    FROM
      sales s
      JOIN product_details pd ON s.prod_id = pd.product_id
    GROUP BY
      1,
      2
  )
SELECT
  category_name,
  segment_name,
  ROUND(
    total_raw_revenue / SUM(total_raw_revenue) OVER (
      PARTITION BY
        category_name
    ) * 100,
    2
  ) percentage_split
FROM
  raw_revenue;
```

#### Result set:

| category_name | segment_name | percentage_split |
|---------------|--------------|------------------|
| Mens          | Shirt        | 56.87            |
| Mens          | Socks        | 43.13            |
| Womens        | Jeans        | 36.21            |
| Womens        | Jacket       | 63.79            |

***

### 8. What is the percentage split of total revenue by category?

```sql
WITH
  raw_revenue AS (
    SELECT
      category_name,
      SUM(qty * s.price) total_raw_revenue
    FROM
      sales s
      JOIN product_details pd ON s.prod_id = pd.product_id
    GROUP BY
      1
  )
SELECT
  category_name,
  ROUND(
    total_raw_revenue / SUM(total_raw_revenue) OVER () * 100,
    2
  ) percentage_split
FROM
  raw_revenue;
```

#### Result set:

| category_name | percentage_split |
|---------------|------------------|
| Womens        | 44.62            |
| Mens          | 55.38            |

***

### 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

```sql
WITH
  t1 AS (
    SELECT
      product_name,
      COUNT(*) appearance
    FROM
      sales s
      JOIN product_details pd ON pd.product_id = s.prod_id
    GROUP BY
      1
  ),
  t2 AS (
    SELECT
      COUNT(DISTINCT (txn_id)) total
    FROM
      sales
  )
SELECT
  product_name,
  ROUND(appearance / total * 100, 2) penetration_rate
FROM
  t1
  JOIN t2
ORDER BY
  2 DESC;
```

#### Result set:

| product_name                     | penetration_rate |
|----------------------------------|------------------|
| Navy Solid Socks - Mens          | 51.24            |
| Grey Fashion Jacket - Womens     | 51.00            |
| Navy Oversized Jeans - Womens    | 50.96            |
| White Tee Shirt - Mens           | 50.72            |
| Blue Polo Shirt - Mens           | 50.72            |
| Pink Fluro Polkadot Socks - Mens | 50.32            |
| Indigo Rain Jacket - Womens      | 50.00            |
| Khaki Suit Jacket - Womens       | 49.88            |
| Black Straight Jeans - Womens    | 49.84            |
| White Striped Socks - Mens       | 49.72            |
| Cream Relaxed Jeans - Womens     | 49.72            |
| Teal Button Up Shirt - Mens      | 49.68            |

***

### 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

```sql
-- I believe this could be dont by getting all possible combinations of 3 products together then group them by txn_id and count how many time each combination appeared
WITH
  p AS (
    SELECT
      txn_id tid,
      product_name pn
    FROM
      sales s
      JOIN product_details pd ON s.prod_id = pd.product_id
  ),
  combine AS (
    SELECT
      p.pn pn1,
      p1.pn pn2,
      p2.pn pn3,
      COUNT(*) tpt,
      ROW_NUMBER() OVER (
        ORDER BY
          COUNT(*) DESC
      ) rn
    FROM
      p
      JOIN p p1 ON p.tid = p1.tid
      AND p.pn != p1.pn
      AND p.pn < p1.pn
      JOIN p p2 ON p.tid = p2.tid
      AND p.pn != p2.pn
      AND p1.pn != p2.pn
      AND p.pn < p2.pn
      AND p1.pn < p2.pn
    GROUP BY
      1,
      2,
      3
  )
SELECT
  pn1 product_1,
  pn2 product_2,
  pn3 product_3,
  tpt times_purchased_together
FROM
  combine
WHERE
  rn = 1;
```

#### Result set:

| product_1                    | product_2                  | product_3                | times_purchased_together |
|------------------------------|----------------------------|--------------------------|--------------------------|
| Grey Fashion Jacket - Womens | Teal Button Up Shirt - Mens| White Tee Shirt - Mens   | 352                      |

***

