## Case Study #8: Fresh Segments - Segment Analysis

1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year
2. Which 5 interests had the lowest average ranking value?
3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?

### 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep the corresponding month_year

- For bottom 10:

```sql
WITH
  l10 AS (
    SELECT
      month_year,
      interest_id,
      composition,
      ROW_NUMBER() OVER (
        PARTITION BY
          month_year
        ORDER BY
          composition
      ) rn
    FROM
      interest_metrics
  )
SELECT
  month_year,
  interest_id,
  MIN(composition) composition
FROM
  l10
WHERE
  rn <= 10
GROUP BY
  1,
  2;
```

#### Sample Result set:

| month_year | interest_id | composition |
|------------|-------------|-------------|
| 2018-07-01 | 6065        | 1.71        |
| 2018-07-01 | 6050        | 1.77        |
| 2018-07-01 | 10953       | 1.81        |
| 2018-07-01 | 2           | 1.81        |
| 2018-07-01 | 15884       | 1.82        |
| 2018-07-01 | 19591       | 1.9         |
| 2018-07-01 | 19599       | 1.92        |
| 2018-07-01 | 19632       | 1.96        |
| 2018-07-01 | 19615       | 2.01        |
| 2018-07-01 | 6047        | 2.04        |

- For top 10:

```sql
WITH
  h10 AS (
    SELECT
      month_year,
      interest_id,
      composition,
      ROW_NUMBER() OVER (
        PARTITION BY
          month_year
        ORDER BY
          composition DESC
      ) rn
    FROM
      interest_metrics
  )
SELECT
  month_year,
  interest_id,
  MAX(composition) composition
FROM
  h10
WHERE
  rn <= 10
GROUP BY
  1,
  2;
```

#### Sample Result set:

| month_year | interest_id | composition |
|------------|-------------|-------------|
| 2018-07-01 | 6284        | 18.82       |
| 2018-07-01 | 39          | 17.44       |
| 2018-07-01 | 77          | 17.19       |
| 2018-07-01 | 171         | 14.91       |
| 2018-07-01 | 4898        | 14.23       |
| 2018-07-01 | 6286        | 14.1        |
| 2018-07-01 | 4           | 13.97       |
| 2018-07-01 | 17786       | 13.67       |
| 2018-07-01 | 6184        | 13.35       |
| 2018-07-01 | 4897        | 12.93       |

***

### 2. Which 5 interests had the lowest average ranking value?

```sql
SELECT
  interest_name,
  AVG(ranking) avg_ranking
FROM
  interest_metrics me
  JOIN interest_map ma ON me.interest_id = ma.id
GROUP BY
  1
ORDER BY
  2
LIMIT
  5;
```

#### Result set:

| interest_name                  | avg_ranking |
|--------------------------------|-------------|
| Winter Apparel Shoppers        | 1.0000      |
| Fitness Activity Tracker Users | 4.1111      |
| Mens Shoe Shoppers             | 5.9286      |
| Shoe Shoppers                  | 9.3571      |
| Preppy Clothing Shoppers       | 11.8571     |

***

### 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?

```sql
SELECT
  interest_name,
  ROUND(STDDEV_SAMP(percentile_ranking), 2) std_dev
FROM
  interest_metrics me
  JOIN interest_map ma ON me.interest_id = ma.id
GROUP BY
  1
ORDER BY
  2 DESC
LIMIT
  5;
```

#### Result set:

| interest_name                              | std_dev |
|--------------------------------------------|---------|
| Techies                                    | 30.18   |
| Entertainment Industry Decision Makers     | 28.97   |
| Oregon Trip Planners                       | 28.32   |
| Personalized Gift Shoppers                 | 26.24   |
| Tampa and St Petersburg Trip Planners      | 25.61   |

***

### 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?

```sql
WITH
  sd AS (
    SELECT
      interest_id,
      ROUND(STDDEV_SAMP(percentile_ranking), 2) std_dev
    FROM
      interest_metrics me
    GROUP BY
      1
    ORDER BY
      2 DESC
    LIMIT
      5
  ),
  t1 AS (
    SELECT
      interest_name,
      month_year,
      percentile_ranking,
      ROW_NUMBER() OVER (
        PARTITION BY
          interest_name
        ORDER BY
          percentile_ranking
      ) min_rn,
      ROW_NUMBER() OVER (
        PARTITION BY
          interest_name
        ORDER BY
          percentile_ranking DESC
      ) max_rn
    FROM
      interest_metrics me
      JOIN interest_map ma ON me.interest_id = ma.id
    WHERE
      interest_id IN (
        SELECT
          interest_id
        FROM
          sd
      )
    GROUP BY
      1,
      2,
      3
  )
SELECT
  interest_name,
  month_year,
  percentile_ranking
FROM
  t1
WHERE
  min_rn = 1
  OR max_rn = 1
ORDER BY
  1,
  2;
```

#### Result set:

| interest_name                          | month_year  | percentile_ranking |
|----------------------------------------|-------------|--------------------|
| Entertainment Industry Decision Makers | 2018-07-01  | 86.15              |
| Entertainment Industry Decision Makers | 2019-08-01  | 11.23              |
| Oregon Trip Planners                   | 2018-11-01  | 82.44              |
| Oregon Trip Planners                   | 2019-07-01  | 2.2                |
| Personalized Gift Shoppers             | 2019-03-01  | 73.15              |
| Personalized Gift Shoppers             | 2019-06-01  | 5.7                |
| Tampa and St Petersburg Trip Planners  | 2018-07-01  | 75.03              |
| Tampa and St Petersburg Trip Planners  | 2019-03-01  | 4.84               |
| Techies                                | 2018-07-01  | 86.69              |
| Techies                                | 2019-08-01  | 7.92               |

-- All of them seem to be in trending for a very short time, then dropped off completely.

***


