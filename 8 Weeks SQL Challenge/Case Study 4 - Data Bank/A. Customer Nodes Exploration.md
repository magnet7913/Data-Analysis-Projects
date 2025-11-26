## Case Study #4: Data Bank - Customer Nodes Exploration

## Case Study Questions

1. How many unique nodes are there on the Data Bank system?
2. What is the number of nodes per region?
3. How many customers are allocated to each region?
4. How many days on average are customers reallocated to a different node?
5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

***

###  1. How many unique nodes are there on the Data Bank system?
###  2. What is the number of nodes per region?

```sql
SELECT
  region_id,
  COUNT(DISTINCT (node_id)) AS node_count
FROM
  customer_nodes
GROUP BY
  1
ORDER BY
  1;
``` 
	
#### Result set:

| region_id | node_count |
|-----------|------------|
| 1         | 5          |
| 2         | 5          |
| 3         | 5          |
| 4         | 5          |
| 5         | 5          |

- There are 5 unique nodes per region, therefore 25 total unique nodes

***

###  3. How many customers are allocated to each region?

```sql
SELECT
  region_id,
  COUNT(DISTINCT (customer_id)) customer_count
FROM
  customer_nodes
GROUP BY
  1;
``` 
	
#### Result set:

| region_id | customer_count |
|-----------|----------------|
| 1         | 110            |
| 2         | 105            |
| 3         | 102            |
| 4         | 95             |
| 5         | 88             |

***

###  4. How many days on average are customers reallocated to a different node?

```sql
-- There are entries with 9999-12-31 as end date, I would assume this mean the information is saved permanently in that node, there for would not be counted toward the average
SELECT
  ROUND(AVG(DATEDIFF (end_date, start_date))) AS avg_till_reallocated
FROM
  customer_nodes
WHERE
  end_date < NOW()
ORDER BY
  1 DESC;
``` 
	
#### Result set:

| avg_till_reallocated |
|----------------------|
| 15                   |

***

###  5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

```sql
WITH
  cte AS (
    SELECT
      *
    FROM
      (
        SELECT
          region_id,
          datediff (end_date, start_date) AS date_diff,
          ROW_NUMBER() OVER (
            PARTITION BY
              region_id
            ORDER BY
              datediff (end_date, start_date)
          ) rn,
          COUNT(*) OVER (
            PARTITION BY
              region_id
          ) total_count
        FROM
          customer_nodes
        WHERE
          end_date < NOW()
      ) t
  )
SELECT
  region_id,
  MAX(
    CASE
      WHEN rn = CEIL(0.5 * total_count) THEN date_diff
    END
  ) AS median,
  MAX(
    CASE
      WHEN rn = CEIL(0.8 * total_count) THEN date_diff
    END
  ) AS p80,
  MAX(
    CASE
      WHEN rn = CEIL(0.95 * total_count) THEN date_diff
    END
  ) AS p95
FROM
  cte
GROUP BY
  1;
``` 
	
#### Result set:

| region_id | median | p80 | p95 |
|-----------|--------|-----|-----|
| 1         | 15     | 23  | 28  |
| 2         | 15     | 23  | 28  |
| 3         | 15     | 24  | 28  |
| 4         | 15     | 23  | 28  |
| 5         | 15     | 24  | 28  |

***