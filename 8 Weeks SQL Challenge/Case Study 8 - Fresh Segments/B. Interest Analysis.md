## Case Study #8: Fresh Segments - Interest Analysis

1. Which interests have been present in all month_year dates in our dataset?
2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?
4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
5. After removing these interests - how many unique interests are there for each month?

### 1. Which interests have been present in all month_year dates in our dataset?

```sql
SELECT
  MIN(month_year),
  MAX(month_year)
FROM
  interest_metrics;
```
- The Dataset ran from Jul 2018 to Aug 2019, meaning if an interests appeared in all month_year, its sum(month(month_year)) must be equal to 93

```sql
SELECT
  interest_id,
  interest_name
FROM
  (
    SELECT
      interest_id,
      SUM(MONTH (month_year)) total_month
    FROM
      interest_metrics
    GROUP BY
      1
  ) t
  JOIN interest_map ma ON t.interest_id = ma.id
WHERE
  total_month = 93;
```

#### Sample Result set:

| interest_id | interest_name                              |
|-------------|--------------------------------------------|
| 32486       | Vacation Rental Accommodation Researchers  |
| 18923       | Online Home Decor Shoppers                 |
| 100         | Nutrition Conscious Eaters                 |
| 79          | Luxury Travel Researchers                  |
| 6110        | Apartment Furniture Shoppers               |
| 6217        | Weight Loss Researchers                    |
| 4           | Luxury Retail Researchers                  |
| 6218        | Running Enthusiasts                        |
| 171         | Shoe Shoppers                              |
| 19613       | Land Rover Shoppers                        |
| 17          | MLB Fans                                   |

***

### 2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?

```sql
WITH
  t1 AS (
    SELECT DISTINCT
      (interest_id) iid,
      COUNT(month_year) mcnt
    FROM
      interest_metrics
    GROUP BY
      1
  ),
  t2 AS (
    SELECT
      mcnt,
      COUNT(iid) icnt
    FROM
      t1
    GROUP BY
      1
  ),
  t3 AS (
    SELECT
      mcnt,
      icnt,
      ROUND(
        SUM(icnt) OVER (
          ORDER BY
            mcnt DESC
        ) / SUM(icnt) OVER (),
        2
      ) cumulative_perc
    FROM
      t2
    ORDER BY
      1 DESC
  )
SELECT
  *
FROM
  t3
WHERE
  cumulative_perc >= 0.9;
```

#### Result set:

| mcnt | icnt | cumulative_perc |
|------|------|-----------------|
| 6    | 33   | 0.91            |
| 5    | 38   | 0.94            |
| 4    | 32   | 0.97            |
| 3    | 15   | 0.98            |
| 2    | 12   | 0.99            |
| 1    | 13   | 1.00            |

***

### 3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?

```sql
-- Lets get the list of interest with less 6 months appearance
WITH
  t1 AS (
    SELECT
      interest_id
    FROM
      interest_metrics
    GROUP BY
      1
    HAVING
      COUNT(DISTINCT month_year) < 6
  )
  -- Then list of records to be removed
SELECT
  COUNT(*) records_to_remove
FROM
  interest_metrics
WHERE
  interest_id IN (
    SELECT
      interest_id
    FROM
      t1
  );
```

#### Result set:

| records_to_remove |
|-------------------|
| 400               |

***

### 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.

```sql
WITH
  t1 AS (
    SELECT
      interest_id
    FROM
      interest_metrics
    GROUP BY
      1
    HAVING
      COUNT(DISTINCT month_year) < 6
  ),
  t2 AS (
    SELECT
      month_year,
      COUNT(DISTINCT interest_id) existing_interest,
      SUM(
        CASE
          WHEN interest_id IN (
            SELECT
              interest_id
            FROM
              t1
          ) THEN 1
        END
      ) interest_to_remove
    FROM
      interest_metrics
    GROUP BY
      1
  )
SELECT
  *,
  ROUND(interest_to_remove / existing_interest * 100, 2) remove_ratio
FROM
  t2;
```

#### Result set:

| month_year | existing_interest | interest_to_remove | remove_ratio |
|------------|-------------------|--------------------|--------------|
| 2018-07-01 | 729               | 20                 | 2.74         |
| 2018-08-01 | 767               | 15                 | 1.96         |
| 2018-09-01 | 780               | 6                  | 0.77         |
| 2018-10-01 | 857               | 4                  | 0.47         |
| 2018-11-01 | 928               | 3                  | 0.32         |
| 2018-12-01 | 995               | 9                  | 0.90         |
| 2019-01-01 | 973               | 7                  | 0.72         |
| 2019-02-01 | 1121              | 49                 | 4.37         |
| 2019-03-01 | 1136              | 58                 | 5.11         |
| 2019-04-01 | 1099              | 64                 | 5.82         |
| 2019-05-01 | 857               | 30                 | 3.50         |
| 2019-06-01 | 824               | 20                 | 2.43         |
| 2019-07-01 | 864               | 28                 | 3.24         |
| 2019-08-01 | 1149              | 87                 | 7.57         |

-- The affected interest took a small portion of the record of each month, I think it it safe to remove them

```sql
WITH
  t1 AS (
    SELECT
      interest_id
    FROM
      interest_metrics
    GROUP BY
      1
    HAVING
      COUNT(DISTINCT month_year) < 6
  )
DELETE FROM interest_metrics
WHERE
  interest_id IN (
    SELECT
      interest_id
    FROM
      t1
  )
```

***

### 5. After removing these interests - how many unique interests are there for each month?

```sql
SELECT
  month_year,
  COUNT(DISTINCT (interest_id)) interest_count
FROM
  interest_metrics
GROUP BY
  1;
```

#### Result set:

| month_year | interest_count |
|------------|----------------|
| 2018-07-01 | 709            |
| 2018-08-01 | 752            |
| 2018-09-01 | 774            |
| 2018-10-01 | 853            |
| 2018-11-01 | 925            |
| 2018-12-01 | 986            |
| 2019-01-01 | 966            |
| 2019-02-01 | 1072           |
| 2019-03-01 | 1078           |
| 2019-04-01 | 1035           |
| 2019-05-01 | 827            |
| 2019-06-01 | 804            |
| 2019-07-01 | 836            |
| 2019-08-01 | 1062           |

***