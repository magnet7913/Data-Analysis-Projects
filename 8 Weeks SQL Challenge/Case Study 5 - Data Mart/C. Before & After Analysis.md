## Case Study #5: Data Mart - Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of **2020-06-15** as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:
1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
2. What about the entire 12 weeks before and after?
3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

###  1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

```sql
SELECT DISTINCT
  (week_date),
  ABS(ROUND(datediff (week_date, '2020-06-15') / 7)) AS week_diff
FROM
  clean_weekly_sales
WHERE
  ABS(ROUND(datediff (week_date, '2020-06-15') / 7)) <= 4
ORDER BY
  1 ASC;
``` 
	
#### Result set:

| week_date  | week_diff |
|------------|-----------|
| 2020-05-18 | 4         |
| 2020-05-25 | 3         |
| 2020-06-01 | 2         |
| 2020-06-08 | 1         |
| 2020-06-15 | 0         |
| 2020-06-22 | 1         |
| 2020-06-29 | 2         |
| 2020-07-06 | 3         |
| 2020-07-13 | 4         |

- Since our dataset is weekly based, and the week 2020-06-15 is the base line, then the 4 weeks after the change should be from 2020-06-15 to 2020-07-06.
- And for 4 weeks before the change should be from 2020-05-18 upto 2020-06-8 

```sql
SELECT
  sales_4_weeks_bfr,
  sales_4_weeks_aft,
  CONCAT(
    ROUND(
      (sales_4_weeks_aft / sales_4_weeks_bfr - 1) * 100,
      2
    ),
    " %"
  ) changes_compare_to_before
FROM
  (
    SELECT
      SUM(sales) sales_4_weeks_bfr
    FROM
      clean_weekly_sales
    WHERE
      ROUND(DATEDIFF (week_date, '2020-06-15') / 7) BETWEEN -4 AND -1
  ) a
  CROSS JOIN (
    SELECT
      SUM(sales) sales_4_weeks_aft
    FROM
      clean_weekly_sales
    WHERE
      ROUND(DATEDIFF (week_date, '2020-06-15') / 7) BETWEEN 0 AND 3
  ) b;
```

#### Result set:

| sales_4_weeks_before | sales_4_weeks_after | change_vs_before |
|----------------------|---------------------|------------------|
| 2,345,878,357        | 2,318,994,169       | -1.15%           |

- The sales result for 4 weeks after the change went down by -1.15%

***

###  2. What about the entire 12 weeks before and after?

```sql
SELECT
  sales_12_weeks_bfr,
  sales_12_weeks_aft,
  CONCAT(
    ROUND(
      (sales_12_weeks_aft / sales_12_weeks_bfr - 1) * 100,
      2
    ),
    " %"
  ) changes_compare_to_before
FROM
  (
    SELECT
      SUM(sales) sales_12_weeks_bfr
    FROM
      clean_weekly_sales
    WHERE
      ROUND(DATEDIFF (week_date, '2020-06-15') / 7) BETWEEN -12 AND -1
  ) a
  CROSS JOIN (
    SELECT
      SUM(sales) sales_12_weeks_aft
    FROM
      clean_weekly_sales
    WHERE
      ROUND(DATEDIFF (week_date, '2020-06-15') / 7) BETWEEN 0 AND 11
  ) b;
```

#### Result set:

| sales_12_weeks_before | sales_12_weeks_after | change_vs_before |
|-----------------------|----------------------|------------------|
| 7,126,273,147         | 6,973,947,753        | -2.14%           |

- Sales result from 12 weeks after the change went down by -2.14% !

***

### 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

- After doing halfway through, I realized i can just use the week_number and still delivered the same result

```sql
SELECT DISTINCT
  (week_number)
FROM
  clean_weekly_sales
WHERE
  week_date = '2020-06-15';
```

| week_number |
|-------------|
| 25          |

- '2020-06-15' is week 25
- For the 4 weeks before, I can just query the result from week_number 21 to 24 and 4 weeks after from week_number 25 - 28
- 12 weeks before is week_number 13 - 24 and 12 weeks after is week_number 25 - 36

```sql
SELECT 
    calendar_year,
    SUM(CASE
        WHEN week_number BETWEEN 21 AND 24 THEN sales
        ELSE 0
    END) 4_wk_bf,
    SUM(CASE
        WHEN week_number BETWEEN 25 AND 28 THEN sales
        ELSE 0
    END) 4_wk_af,
    SUM(CASE
        WHEN week_number BETWEEN 13 AND 24 THEN sales
        ELSE 0
    END) 12_wk_bf,
    SUM(CASE
        WHEN week_number BETWEEN 25 AND 36 THEN sales
        ELSE 0
    END) 12_wk_af
FROM
    clean_weekly_sales
GROUP BY 1
;
```

#### Result set:

| calendar_year | 4_wk_before   | 4_wk_after    | 12_wk_before  | 12_wk_after   |
|---------------|---------------|---------------|---------------|---------------|
| 2020          | 2,345,878,357 | 2,318,994,169 | 7,126,273,147 | 6,973,947,753 |
| 2019          | 2,249,989,796 | 2,252,326,390 | 6,883,386,397 | 6,862,646,103 |
| 2018          | 2,125,140,809 | 2,129,242,914 | 6,396,562,317 | 6,500,818,510 |

- In 2019 , the 4 weeks period shows a 0.10% increment in sales, while the 12 weeks period showed a -0.30% decreasement in sales
- In 2018, the 4 weeks period shows a 0.19% increment in sales, while the 12 weeks period showed a 1.63% increment in sales
- Meaning in this metric, the drop in sales in 2020 is more severe than both 2018 and 2019 (-1.15% for 4 weeks and -2.14% for 12 weeks).