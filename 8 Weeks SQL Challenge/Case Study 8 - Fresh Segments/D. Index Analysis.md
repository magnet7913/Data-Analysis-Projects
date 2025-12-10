## Case Study #8: Fresh Segments - Index Analysis

The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

1. What is the top 10 interests by the average composition for each month?
2. For all of these top 10 interests - which interest appears the most often?
3. What is the average of the average composition for the top 10 interests for each month?
4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.

Required output for question 4:

| month_year | interest_name                  | max_index_composition | 3_month_moving_avg | 1_month_ago                          | 2_months_ago                         |
|------------|--------------------------------|-----------------------|--------------------|--------------------------------------|--------------------------------------|
| 2018-09-01 | Work Comes First Travelers     | 8.26                  | 7.61               | Las Vegas Trip Planners: 7.21        | Las Vegas Trip Planners: 7.36        |
| 2018-10-01 | Work Comes First Travelers     | 9.14                  | 8.20               | Work Comes First Travelers: 8.26     | Las Vegas Trip Planners: 7.21        |
| 2018-11-01 | Work Comes First Travelers     | 8.28                  | 8.56               | Work Comes First Travelers: 9.14     | Work Comes First Travelers: 8.26     |
| 2018-12-01 | Work Comes First Travelers     | 8.31                  | 8.58               | Work Comes First Travelers: 8.28     | Work Comes First Travelers: 9.14     |
| 2019-01-01 | Work Comes First Travelers     | 7.66                  | 8.08               | Work Comes First Travelers: 8.31     | Work Comes First Travelers: 8.28     |
| 2019-02-01 | Work Comes First Travelers     | 7.66                  | 7.88               | Work Comes First Travelers: 7.66     | Work Comes First Travelers: 8.31     |
| 2019-03-01 | Alabama Trip Planners          | 6.54                  | 7.29               | Work Comes First Travelers: 7.66     | Work Comes First Travelers: 7.66     |
| 2019-04-01 | Solar Energy Researchers       | 6.28                  | 6.83               | Alabama Trip Planners: 6.54          | Work Comes First Travelers: 7.66     |
| 2019-05-01 | Readers of Honduran Content    | 4.41                  | 5.74               | Solar Energy Researchers: 6.28       | Alabama Trip Planners: 6.54          |
| 2019-06-01 | Las Vegas Trip Planners        | 2.77                  | 4.49               | Readers of Honduran Content: 4.41    | Solar Energy Researchers: 6.28       |
| 2019-07-01 | Las Vegas Trip Planners        | 2.82                  | 3.33               | Las Vegas Trip Planners: 2.77        | Readers of Honduran Content: 4.41    |
| 2019-08-01 | Cosmetics and Beauty Shoppers  | 2.73                  | 2.77               | Las Vegas Trip Planners: 2.82        | Las Vegas Trip Planners: 2.77        |

### The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.
Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

- I would create a temp table for this section for easier access to avg_composition

```sql
CREATE TEMPORARY TABLE avg_compo AS (
  SELECT
    month_year,
    interest_id,
    ROUND(composition / index_value, 2) ac,
    ROW_NUMBER() OVER (
      PARTITION BY
        month_year
      ORDER BY
        ROUND(composition / index_value, 2) DESC
    ) rn
  FROM
    interest_metrics
);
```

### 1. What is the top 10 interests by the average composition for each month?

```sql
SELECT
  month_year,
  interest_name,
  ac
FROM
  avg_compo ac
  JOIN interest_map ma ON ac.interest_id = ma.id
WHERE
  rn <= 10
ORDER BY
  1;
```


#### Sample Result set:

| month_year | interest_name                                   | ac   |
|------------|-------------------------------------------------|------|
| 2018-07-01 | Furniture Shoppers                              | 6.51 |
| 2018-07-01 | Luxury Retail Shoppers                          | 6.61 |
| 2018-07-01 | HDTV Researchers                                | 4.71 |
| 2018-07-01 | Cosmetics and Beauty Shoppers                   | 6.78 |
| 2018-07-01 | Recently Retired Individuals                    | 5.72 |
| 2018-07-01 | Gym Equipment Owners                            | 6.94 |
| 2018-07-01 | Las Vegas Trip Planners                         | 7.36 |
| 2018-07-01 | Asian Food Enthusiasts                          | 6.1  |
| 2018-07-01 | Work Comes First Travelers                      | 4.8  |
| 2018-07-01 | Family Adventures Travelers                     | 4.85 |
| 2018-08-01 | Furniture Shoppers                              | 6.3  |
| 2018-08-01 | Luxury Retail Shoppers                          | 6.53 |
| 2018-08-01 | Cosmetics and Beauty Shoppers                   | 6.28 |
| 2018-08-01 | Luxury Bedding Shoppers                         | 4.72 |
| 2018-08-01 | Recently Retired Individuals                    | 5.58 |
| 2018-08-01 | Gym Equipment Owners                            | 6.62 |
| 2018-08-01 | Las Vegas Trip Planners                         | 7.21 |

***

### 2. For all of these top 10 interests - which interest appears the most often?

- We would just need to add a cte to the previous query to get the answer

```sql
WITH
  t1 AS (
    SELECT
      month_year,
      interest_name,
      ac
    FROM
      avg_compo ac
      JOIN interest_map ma ON ac.interest_id = ma.id
    WHERE
      rn <= 10
  )
SELECT
  interest_name,
  COUNT(*) appearance
FROM
  t1
GROUP BY
  1
ORDER BY
  2 DESC;
```


#### Sample Result set:

| interest_name                                 | appearance |
|-----------------------------------------------|------------|
| Alabama Trip Planners                         | 10         |
| Luxury Bedding Shoppers                       | 10         |
| Solar Energy Researchers                      | 10         |
| Readers of Honduran Content                   | 9          |
| Nursing and Physicians Assistant Journal Researchers | 9          |
| New Years Eve Party Ticket Purchasers         | 9          |
| Work Comes First Travelers                    | 8          |
| Teen Girl Clothing Shoppers                   | 8          |
| Christmas Celebration Researchers             | 7          |
| Las Vegas Trip Planners                       | 5          |
| Gym Equipment Owners                          | 5          |
| Cosmetics and Beauty Shoppers                 | 5          |
| Luxury Retail Shoppers                        | 5          |
| Furniture Shoppers                            | 5          |
| Asian Food Enthusiasts                        | 5          |

***

### 3. What is the average of the average composition for the top 10 interests for each month?

```sql
SELECT
  month_year,
  ROUND(AVG(ac), 2) avg_avg_compo
FROM
  avg_compo
WHERE
  rn <= 10
GROUP BY
  1;
```


#### Result set:

| month_year | avg_avg_compo |
|------------|---------------|
| 2018-07-01 | 6.04          |
| 2018-08-01 | 5.94          |
| 2018-09-01 | 6.89          |
| 2018-10-01 | 7.07          |
| 2018-11-01 | 6.62          |
| 2018-12-01 | 6.65          |
| 2019-01-01 | 6.4           |
| 2019-02-01 | 6.58          |
| 2019-03-01 | 6.17          |
| 2019-04-01 | 5.75          |
| 2019-05-01 | 3.54          |
| 2019-06-01 | 2.43          |
| 2019-07-01 | 2.76          |
| 2019-08-01 | 2.63          |

***

### 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.

```sql
WITH
  t1 AS (
    SELECT
      month_year,
      interest_name,
      ac,
      rn
    FROM
      avg_compo ac
      JOIN interest_map ma ON ac.interest_id = ma.id
  ),
  t2 AS (
    SELECT
      month_year,
      interest_name,
      ac,
      lag (ac, 1, 0) OVER () l1ac,
      lag (ac, 2, 0) OVER () l2ac,
      lag (interest_name, 1, NULL) OVER () l1,
      lag (interest_name, 2, NULL) OVER () l2
    FROM
      t1
    WHERE
      rn = 1
  )
SELECT
  month_year,
  interest_name,
  ac max_index_composition,
  ROUND((ac + l1ac + l2ac) / 3, 2) `3_month_moving_avg`,
  concat (l1, ": ", l1ac) `1_month_ago`,
  concat (l2, ": ", l2ac) `2_month_ago`
FROM
  t2
HAVING
  month_year BETWEEN '2018-09-01' AND '2019-08-01'
```


#### Result set:

| month_year | interest_name                  | max_index_composition | 3_month_moving_avg | 1_month_ago                          | 2_months_ago                         |
|------------|--------------------------------|-----------------------|--------------------|--------------------------------------|--------------------------------------|
| 2018-09-01 | Work Comes First Travelers     | 8.26                  | 7.61               | Las Vegas Trip Planners: 7.21        | Las Vegas Trip Planners: 7.36        |
| 2018-10-01 | Work Comes First Travelers     | 9.14                  | 8.20               | Work Comes First Travelers: 8.26     | Las Vegas Trip Planners: 7.21        |
| 2018-11-01 | Work Comes First Travelers     | 8.28                  | 8.56               | Work Comes First Travelers: 9.14     | Work Comes First Travelers: 8.26     |
| 2018-12-01 | Work Comes First Travelers     | 8.31                  | 8.58               | Work Comes First Travelers: 8.28     | Work Comes First Travelers: 9.14     |
| 2019-01-01 | Work Comes First Travelers     | 7.66                  | 8.08               | Work Comes First Travelers: 8.31     | Work Comes First Travelers: 8.28     |
| 2019-02-01 | Work Comes First Travelers     | 7.66                  | 7.88               | Work Comes First Travelers: 7.66     | Work Comes First Travelers: 8.31     |
| 2019-03-01 | Alabama Trip Planners          | 6.54                  | 7.29               | Work Comes First Travelers: 7.66     | Work Comes First Travelers: 7.66     |
| 2019-04-01 | Solar Energy Researchers       | 6.28                  | 6.83               | Alabama Trip Planners: 6.54          | Work Comes First Travelers: 7.66     |
| 2019-05-01 | Readers of Honduran Content    | 4.41                  | 5.74               | Solar Energy Researchers: 6.28       | Alabama Trip Planners: 6.54          |
| 2019-06-01 | Las Vegas Trip Planners        | 2.77                  | 4.49               | Readers of Honduran Content: 4.41    | Solar Energy Researchers: 6.28       |
| 2019-07-01 | Las Vegas Trip Planners        | 2.82                  | 3.33               | Las Vegas Trip Planners: 2.77        | Readers of Honduran Content: 4.41    |
| 2019-08-01 | Cosmetics and Beauty Shoppers  | 2.73                  | 2.77               | Las Vegas Trip Planners: 2.82        | Las Vegas Trip Planners: 2.77        |

***