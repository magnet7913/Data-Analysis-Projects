## Case Study #6: Balanced Tree Clothing Co. - Transaction Analysis

1. How many unique transactions were there?
2. What is the average unique products purchased in each transaction?
3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
4. What is the average discount value per transaction?
5. What is the percentage split of all transactions for members vs non-members?
6. What is the average revenue for member transactions and non-member transactions?

### 1. How many unique transactions were there?

```sql
SELECT
  COUNT(DISTINCT (txn_id)) unique_transaction
FROM
  sales;
```

#### Result set:

| total_discounted |
|------------------|
| 156229.14        |

***

### 2. What is the average unique products purchased in each transaction?

```sql
SELECT
  ROUND(AVG(up), 2) unique_products_purchased
FROM
  (
    SELECT DISTINCT
      (txn_id),
      COUNT(*) up
    FROM
      sales
    GROUP BY
      1
  ) t;
```

#### Result set:

| unique_transaction |
|--------------------|
| 2500               |

***

### 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

```sql
SELECT
  percentile * 100 percentile,
  ROUND(AVG(DISTINCT (revenue))) revenue
FROM
  (
    SELECT
      txn_id,
      SUM(qty * price) revenue,
      ROUND(
        PERCENT_RANK() OVER (
          ORDER BY
            SUM(qty * price)
        ),
        2
      ) percentile
    FROM
      sales
    GROUP BY
      1
    ORDER BY
      2 DESC
  ) t
WHERE
  percentile IN (.25, .5, .75)
GROUP BY
  1;
```

#### Result set:

| percentile | revenue |
|------------|---------|
| 25         | 377     |
| 50         | 510     |
| 75         | 647     |

***

### 4. What is the average discount value per transaction?

```sql
WITH
  sv AS (
    SELECT
      txn_id,
      SUM(qty * price * (discount / 100)) discounted
    FROM
      sales
    GROUP BY
      1
  )
SELECT
  ROUND(AVG(discounted), 2) discounted
FROM
  sv;
```

#### Result set:

| discounted |
|------------|
| 62.49      |

***

### 5. What is the percentage split of all transactions for members vs non-members?

```sql
WITH
  check_member AS (
    SELECT
      COUNT(
        DISTINCT (
          CASE
            WHEN member = 1 THEN txn_id
          END
        )
      ) AS member_transaction,
      COUNT(
        DISTINCT (
          CASE
            WHEN member = 0 THEN txn_id
          END
        )
      ) AS non_member_transaction
    FROM
      sales
  )
SELECT
  member_transaction,
  ROUND(
    member_transaction / (member_transaction + non_member_transaction) * 100,
    2
  ) member_percent,
  non_member_transaction,
  ROUND(
    non_member_transaction / (member_transaction + non_member_transaction) * 100,
    2
  ) non_member_percent
FROM
  check_member;
```

#### Result set:

| member_transaction | member_percent | non_member_transaction | non_member_percent |
|--------------------|----------------|-------------------------|--------------------|
| 1505               | 60.20          | 995                     | 39.80              |

***

### 6. What is the average revenue for member transactions and non-member transactions?

```sql
-- I would calculate revenue after Discount
WITH
  check_member_revenue AS (
    SELECT
      txn_id,
      SUM(
        CASE
          WHEN member = 1 THEN qty * price * (1 - discount / 100)
        END
      ) AS member_transaction,
      SUM(
        CASE
          WHEN member = 0 THEN qty * price * (1 - discount / 100)
        END
      ) AS non_member_transaction
    FROM
      sales
    GROUP BY
      1
  )
SELECT
  ROUND(AVG(member_transaction), 2) member_transaction,
  ROUND(AVG(non_member_transaction), 2) non_member_transaction
FROM
  check_member_revenue;
```

#### Result set:

| member_transaction | non_member_transaction |
|--------------------|------------------------|
| 454.14             | 452.01                 |

***