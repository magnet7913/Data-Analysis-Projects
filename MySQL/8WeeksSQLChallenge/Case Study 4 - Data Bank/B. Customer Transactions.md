## Case Study #4: Data Bank - Customer Transactions - WIP

## Case Study Questions

1. What is the unique count and total amount for each transaction type?
2. What is the average total historical deposit counts and amounts for all customers?
3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
4. What is the closing balance for each customer at the end of the month?
5. What is the percentage of customers who increase their closing balance by more than 5%?

***

###  1. What is the unique count and total amount for each transaction type?

```sql
SELECT
  txn_type,
  SUM(txn_amount) total_amount,
  COUNT(*) transaction_count
FROM
  customer_transactions
GROUP BY
  1;
``` 
	
#### Result set:

| txn_type   | total_amount | transaction_count |
|------------|--------------|-------------------|
| deposit    | 1359168      | 2671              |
| withdrawal | 793003       | 1580              |
| purchase   | 806537       | 1617              |

***

###  2. What is the average total historical deposit counts and amounts for all customers?

```sql
SELECT
  ROUND(AVG(transaction_count)) avg_count,
  ROUND(AVG(total), 2) avg_total
FROM
  (
    SELECT
      customer_id,
      COUNT(*) transaction_count,
      SUM(txn_amount) AS total
    FROM
      customer_transactions
    WHERE
      txn_type IN ('deposit')
    GROUP BY
      1
  ) t;
``` 
	
#### Result set:

| avg_count | avg_total |
|-----------|-----------|
| 5         | 2718.34   |

***

###  3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

```sql
SELECT
  mth,
  COUNT(DISTINCT (customer_id)) customer_count
FROM
  (
    SELECT
      MONTH (txn_date) mth,
      customer_id,
      SUM(
        CASE
          WHEN txn_type = 'deposit' THEN 1
          ELSE 0
        END
      ) dep_count,
      SUM(
        CASE
          WHEN txn_type = 'withdrawal' THEN 1
          ELSE 0
        END
      ) wd_count,
      SUM(
        CASE
          WHEN txn_type = 'purchase' THEN 1
          ELSE 0
        END
      ) pc_count
    FROM
      customer_transactions
    GROUP BY
      1,
      2
  ) t
WHERE
  dep_count > 1
  AND (
    wd_count = 1
    OR pc_count = 1
  )
GROUP BY
  1
ORDER BY
  1;
``` 
	
#### Result set:

| mth | customer_count |
|-----|----------------|
| 1   | 115            |
| 2   | 108            |
| 3   | 113            |
| 4   | 50             |

***

###  4. What is the closing balance for each customer at the end of the month?

```sql
-- If we only take the month with activities into account:
WITH
  cte_2 AS (
    WITH
      cte AS (
        SELECT
          customer_id cid,
          MONTH (txn_date) mth,
          SUM(
            CASE
              WHEN txn_type = 'deposit' THEN txn_amount
              ELSE - txn_amount
            END
          ) cash_flow
        FROM
          customer_transactions
        GROUP BY
          1,
          2
        ORDER BY
          1
      )
    SELECT
      *,
      LAG(cash_flow, 1, 0) OVER (
        PARTITION BY
          cid
      ) AS prev_payment
    FROM
      cte
  )
SELECT
  cid,
  mth,
  cash_flow + prev_payment AS closing_balance
FROM
  cte_2;
``` 
	
#### Result set:

| cid | mth | closing_balance |
|-----|-----|-----------------|
| 1   | 1   | 312             |
| 1   | 3   | -640            |
| 2   | 1   | 549             |
| 2   | 3   | 610             |
| 3   | 1   | 144             |
| 3   | 2   | -821            |
| 3   | 3   | -1366           |
| 3   | 4   | 92              |
| 4   | 1   | 848             |
| 4   | 3   | 655             |
| 5   | 1   | 954             |
| 5   | 3   | -1923           |
| 5   | 4   | -3367           |
| 6   | 1   | 733             |
| 6   | 2   | -52             |
| 6   | 3   | -393            |
| 7   | 1   | 964             |
| 7   | 2   | 3173            |
| 7   | 3   | 1569            |
| 7   | 4   | -550            |

```sql
-- Since the data set spans from 2020-01-01 to 2020-04-30, then closing balance of each customer should have 4 months
WITH RECURSIVE
  data AS (
    SELECT
      cid,
      mth,
      closing_balance
    FROM
      (
        WITH
          cte_2 AS (
            WITH
              cte AS (
                SELECT
                  customer_id cid,
                  MONTH (txn_date) mth,
                  SUM(
                    CASE
                      WHEN txn_type = 'deposit' THEN txn_amount
                      ELSE - txn_amount
                    END
                  ) cash_flow
                FROM
                  customer_transactions
                GROUP BY
                  1,
                  2
                ORDER BY
                  1
              )
            SELECT
              *,
              LAG(cash_flow, 1, 0) OVER (
                PARTITION BY
                  cid
              ) AS prev_payment
            FROM
              cte
          )
        SELECT
          cid,
          mth,
          cash_flow + prev_payment AS closing_balance
        FROM
          cte_2
      ) balance
  ),
  cids AS (
    SELECT DISTINCT
      cid
    FROM
      data
  ),
  global_range AS (
    SELECT
      MIN(mth) AS min_mth,
      MAX(mth) AS max_mth
    FROM
      data
  ),
  all_months AS ( -- To get the max and min month of the data set, incase some customer only active for some months
    SELECT
      c.cid,
      gr.min_mth AS mth
    FROM
      cids c
      CROSS JOIN global_range gr
    UNION ALL
    SELECT
      a.cid,
      a.mth + 1
    FROM
      all_months a
      CROSS JOIN global_range gr
    WHERE
      a.mth + 1 <= gr.max_mth
  )
SELECT
  t.cid,
  t.mth,
  t.closing_balance
FROM
  (
    SELECT
      am.cid,
      am.mth,
      b.closing_balance,
      b.mth AS source_mth,
      MAX(b.mth) OVER (
        PARTITION BY
          am.cid,
          am.mth
      ) AS latest_mth
    FROM
      all_months am
      LEFT JOIN data b ON b.cid = am.cid
      AND b.mth <= am.mth
  ) t
WHERE
  t.source_mth = t.latest_mth
ORDER BY
  t.cid,
  t.mth;
```

#### Result set:

| cid | mth | closing_balance |
|-----|-----|-----------------|
| 1   | 1   | 312             |
| 1   | 2   | 312             |
| 1   | 3   | -640            |
| 1   | 4   | -640            |
| 2   | 1   | 549             |
| 2   | 2   | 549             |
| 2   | 3   | 610             |
| 2   | 4   | 610             |
| 3   | 1   | 144             |
| 3   | 2   | -821            |
| 3   | 3   | -1366           |
| 3   | 4   | 92              |
| 4   | 1   | 848             |
| 4   | 2   | 848             |
| 4   | 3   | 655             |
| 4   | 4   | 655             |
| 5   | 1   | 954             |
| 5   | 2   | 954             |
| 5   | 3   | -1923           |
| 5   | 4   | -3367           |
| 6   | 1   | 733             |
| 6   | 2   | -52             |
| 6   | 3   | -393            |
| 6   | 4   | -393            |
| 7   | 1   | 964             |
| 7   | 2   | 3173            |
| 7   | 3   | 1569            |
| 7   | 4   | -550            |

***

###  5. What is the percentage of customers who increase their closing balance by more than 5%?

```sql
-- I assume this question asked the closing balance at the end of month 4 compare to month 1
WITH
  cte_3 AS (
    WITH
      cte_2 AS (
        WITH
          cte AS (
            SELECT
              customer_id cid,
              MONTH (txn_date) mth,
              SUM(
                CASE
                  WHEN txn_type = 'deposit' THEN txn_amount
                  ELSE - txn_amount
                END
              ) cash_flow
            FROM
              customer_transactions
            GROUP BY
              1,
              2
            ORDER BY
              1
          )
        SELECT
          *,
          LAG(cash_flow, 1, 0) OVER (
            PARTITION BY
              cid
          ) AS prev_payment
        FROM
          cte
      )
    SELECT
      cid,
      mth,
      cash_flow + prev_payment AS closing_balance
    FROM
      cte_2
  ),
  cte_min AS (
    SELECT
      cid,
      mth,
      closing_balance
    FROM
      (
        SELECT
          cid,
          mth,
          closing_balance,
          MIN(mth) OVER (
            PARTITION BY
              cid
          ) min_mth
        FROM
          cte_3
      ) t
    WHERE
      mth = min_mth
  ) -- to get balance of the 1st active month
,
  cte_max AS (
    SELECT
      cid,
      mth,
      closing_balance
    FROM
      (
        SELECT
          cid,
          mth,
          closing_balance,
          MAX(mth) OVER (
            PARTITION BY
              cid
          ) max_mth
        FROM
          cte_3
      ) t
    WHERE
      mth = max_mth
  ) -- to get balance of the last active month
SELECT
  COUNT(cid) total_customer,
  SUM(count) increased_at_least_5_percent,
  CONCAT(ROUND(SUM(count) / COUNT(cid) * 100, 2), '%') ratio
FROM
  (
    SELECT
      min.cid,
      CASE
        WHEN min.closing_balance * 1.05 < max.closing_balance THEN 0
        ELSE 1
      END AS count
    FROM
      cte_min min
      JOIN cte_max max ON min.cid = max.cid
  ) t;
``` 
	
#### Result set:

| total_customer | increased_at_least_5_percent | ratio   |
|----------------|------------------------------|---------|
| 500            | 344                          | 68.80%  |

***