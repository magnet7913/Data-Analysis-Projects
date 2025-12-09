## Case Study #8: Fresh Segments - Data Exploration and Cleansing

1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
3. What do you think we should do with these null values in the fresh_segments.interest_metrics
4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?

### 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
- Step 1
```sql
UPDATE interest_metrics
SET
  month_year = NULL;
```
- Step 2
```sql
ALTER TABLE interest_metrics modify month_year date;
```
- Step 3
```sql
UPDATE interest_metrics
SET
  month_year = CAST(CONCAT(_year, '-', _month, '-', '1') AS date);
```

***

### 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
```sql
SELECT
  MONTH,
  count_of_records
FROM
  (
    SELECT
      MONTH (month_year) MONTH,
      CASE
        WHEN MONTH (month_year) IS NULL THEN 1
        ELSE 2
      END rn,
      COUNT(*) count_of_records
    FROM
      interest_metrics
    GROUP BY
      1,
      2
  ) t
ORDER BY
  rn,
  1 DESC;
```

#### Result set:

| month | count_of_records |
|-------|------------------|
|       | 1194             |
| 12    | 995              |
| 11    | 928              |
| 10    | 857              |
| 9     | 780              |
| 8     | 1916             |
| 7     | 1593             |
| 6     | 824              |
| 5     | 857              |
| 4     | 1099             |
| 3     | 1136             |
| 2     | 1121             |
| 1     | 973              |

***

### 3. What do you think we should do with these null values in the fresh_segments.interest_metrics

- Since the null values missed all 3 month, year and month_year value. There is no way to sort them into each month and keeping them around would create more issue when joining table and skew future ranking
- I believe we should delete these entries

```sql
DELETE FROM interest_metrics
WHERE
  month_year IS NULL
  AND _month IS NULL
  AND _year IS NULL;
```

***

### 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?

- For values exist in the interest_metrics table but not in the interest_map table:

```sql
SELECT
  COUNT(DISTINCT (interest_id)) metrics_not_in_map
FROM
  interest_metrics
WHERE
  interest_id NOT IN (
    SELECT
      id
    FROM
      interest_map
  );
```

#### Result set:

| metrics_not_in_map |
|--------------------|
| 0                  |

- For values exist in the interest_map table but not in the interest_metrics table:

```sql
SELECT
  COUNT(DISTINCT (id)) map_not_in_metrics
FROM
  interest_map
WHERE
  id NOT IN (
    SELECT
      interest_id
    FROM
      interest_metrics
  );
```

#### Result set:

| map_not_in_metrics |
|--------------------|
| 7                  |

***

### 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table

- I believe technically this question asked how many time each id from interest_map appeared in interest_metrics

```sql
SELECT
  id,
  COUNT(*) total_count
FROM
  interest_map ma
  LEFT JOIN interest_metrics me ON ma.id = me.interest_id
GROUP BY
  1;
```

#### Sample Result set:

| id | total_count |
|----|-------------|
| 1  | 12          |
| 2  | 11          |
| 3  | 10          |
| 4  | 14          |
| 5  | 14          |
| 6  | 14          |
| 7  | 11          |
| 8  | 13          |
| 12 | 14          |
| 13 | 13          |
| 14 | 12          |
| 15 | 14          |
| 16 | 14          |
| 17 | 14          |
| 18 | 14          |
| 19 | 10          |
| 20 | 14          |
| 21 | 12          |
| 22 | 13          |
| 23 | 6           |
| 24 | 12          |
| 25 | 14          |

***

### 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

- Because there were interest that appeared in the interest_map and not in interest_metrics. The best idea was to LEFT JOIN from interest_map to interest_metrics

```sql
SELECT
  *
FROM
  interest_map ma
  LEFT JOIN interest_metrics me ON ma.id = me.interest_id
WHERE
  interest_id = 21246;
```

#### Result set:

| id    | interest_name                     | interest_summary                                   | created_at           | last_modified        | _month | _year | month_year  | interest_id | composition | index_value | ranking | percentile_ranking |
|-------|-----------------------------------|----------------------------------------------------|----------------------|----------------------|--------|-------|-------------|-------------|-------------|-------------|---------|--------------------|
| 21246 | Readers of El Salvadoran Content  | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04  | 2018-06-11 17:50:04  | 7      | 2018  | 2018-07-01  | 21246       | 2.26        | 0.65        | 722     | 0.96               |
| 21246 | Readers of El Salvadoran Content  | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04  | 2018-06-11 17:50:04  | 8      | 2018  | 2018-08-01  | 21246       | 2.13        | 0.59        | 765     | 0.26               |
| 21246 | Readers of El Salvadoran Content  | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04  | 2018-06-11 17:50:04  | 9      | 2018  | 2018-09-01  | 21246       | 2.06        | 0.61        | 774     | 0.77               |
| 21246 | Readers of El Salvadoran Content  | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04  | 2018-06-11 17:50:04  | 10     | 2018  | 2018-10-01  | 21246       | 1.74        | 0.58        | 855     | 0.23               |
| 21246 | Readers of El Salvadoran Content  | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04  | 2018-06-11 17:50:04  | 11     | 2018  | 2018-11-01  | 21246       | 2.25        | 0.78        | 908     | 2.16               |
| 21246 | Readers of El Salvadoran Content  | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04  | 2018-06-11 17:50:04  | 12     | 2018  | 2018-12-01  | 21246       | 1.97        | 0.7         | 983     | 1.21               |
| 21246 | Readers of El Salvadoran Content  | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04  | 2018-06-11 17:50:04  | 1      | 2019  | 2019-01-01  | 21246       | 2.05        | 0.76        | 954     | 1.95               |
| 21246 | Readers of El Salvadoran Content  | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04  | 2018-06-11 17:50:04  | 2      | 2019  | 2019-02-01  | 21246       | 1.84        | 0.68        | 1109    | 1.07               |
| 21246 | Readers of El Salvadoran Content  | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04  | 2018-06-11 17:50:04  | 3      | 2019  | 2019-03-01  | 21246       | 1.75        | 0.67        | 1123    | 1.14               |
| 21246 | Readers of El Salvadoran Content  | People reading news from El Salvadoran media sources. | 2018-06-11 17:50:04  | 2018-06-11 17:50:04  | 4      | 2019  | 2019-04-01  | 21246       | 1.58        | 0.63        | 1092    | 0.64               |

***

### 7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?

- Yes, these records are valid as long as the month and year value are the same, since month_year was forced to always be the 1st day of the month. Some records generated with in that month could result in month_year value is before the created_at date.
- To check if any records are incorrect, i ran this query:

```sql
WITH
  cte AS (
    SELECT
      *
    FROM
      interest_map ma
      LEFT JOIN interest_metrics me ON ma.id = me.interest_id
  )
SELECT
  *
FROM
  cte
WHERE
  MONTH (created_at) > CAST(_month AS unsigned)
  AND YEAR (created_at) > CAST(_year AS unsigned) -- So we would be sure that the metrics was not created before the map
;
```

#### Result set:
| id | interest_name | interest_summary | created_at | last_modified | _month | _year | month_year | interest_id | composition | index_value | ranking | percentile_ranking |
|----|---------------|------------------|------------|---------------|--------|-------|------------|-------------|-------------|-------------|---------|--------------------|

Luckily none of the records fell into this scenario :)

***