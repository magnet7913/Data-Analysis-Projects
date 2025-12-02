## Case Study #5: Data Mart - Data Exploration

## Case Study Questions
1. What day of the week is used for each week_date value?
2. What range of week numbers are missing from the dataset?
3. How many total transactions were there for each year in the dataset?
4. What is the total sales for each region for each month?
5. What is the total count of transactions for each platform
6. What is the percentage of sales for Retail vs Shopify for each month?
7. What is the percentage of sales by demographic for each year in the dataset?
8. Which age_band and demographic values contribute the most to Retail sales?
9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

***

###  1. What day of the week is used for each week_date value?

```sql
SELECT DISTINCT
  (weekday (week_date)) AS week_date
FROM
  clean_weekly_sales;
``` 
	
#### Result set:

| week_date  |
|------------|
| 0          |

- 100% result is 0, then only Monday is used for each week_date value

***


###  2. What range of week numbers are missing from the dataset?

```sql
SELECT DISTINCT
  (week_number)
FROM
  clean_weekly_sales
ORDER BY
  1;
``` 
	
#### Result set:

| week_number |
|-------------|
| 13          |
| 14          |
| 15          |
| 16          |
| 17          |
| 18          |
| 19          |
| 20          |
| 21          |
| 22          |
| 23          |
| 24          |
| 25          |
| 26          |
| 27          |
| 28          |
| 29          |
| 30          |
| 31          |
| 32          |
| 33          |
| 34          |
| 35          |
| 36          |

- The dataset ran continuously from week 13 to 36. Missing week 1 to 12 and week 37 to 53


***

###  3. How many total transactions were there for each year in the dataset?

```sql
SELECT
  calendar_year,
  COUNT(*) transaction_count
FROM
  clean_weekly_sales
GROUP BY
  1;
``` 
	
#### Result set:

| calendar_year | transaction_count |
|---------------|-------------------|
| 2020          | 5711              |
| 2019          | 5708              |
| 2018          | 5698              |

***

###  4. What is the total sales for each region for each month?

```sql
SELECT
  region,
  calendar_year,
  month_number,
  COUNT(*) transaction_count
FROM
  clean_weekly_sales
GROUP BY
  1,
  2,
  3
ORDER BY
  1,
  2,
  3;
``` 
	
#### Result set:

* Sample result:

| region        | calendar_year | month_number | transaction_count |
|---------------|---------------|--------------|-------------------|
| AFRICA        | 2018          | 3            | 34                |
| AFRICA        | 2018          | 4            | 170               |
| AFRICA        | 2018          | 5            | 136               |
| AFRICA        | 2018          | 6            | 136               |
| AFRICA        | 2018          | 7            | 170               |
| AFRICA        | 2018          | 8            | 136               |
| AFRICA        | 2018          | 9            | 34                |
| AFRICA        | 2019          | 3            | 34                |
| AFRICA        | 2019          | 4            | 170               |
| AFRICA        | 2019          | 5            | 136               |
| AFRICA        | 2019          | 6            | 136               |
| AFRICA        | 2019          | 7            | 170               |
| AFRICA        | 2019          | 8            | 136               |
| AFRICA        | 2019          | 9            | 34                |
| AFRICA        | 2020          | 3            | 68                |
| AFRICA        | 2020          | 4            | 136               |

***

###  5. What is the total count of transactions for each platform

```sql
SELECT
  platform,
  COUNT(*) transaction_count
FROM
  clean_weekly_sales
GROUP BY
  1
ORDER BY
  1;
``` 
	
#### Result set:

| platform | transaction_count |
|----------|-------------------|
| Retail   | 8568              |
| Shopify  | 8549              |

***

###  6. What is the percentage of sales for Retail vs Shopify for each month?

```sql
SELECT
  calendar_year,
  month_number,
  platform,
  SUM(sales) total_sales,
  CONCAT(
    ROUND(
      SUM(sales) / SUM(SUM(sales)) OVER (
        PARTITION BY
          calendar_year,
          month_number
      ) * 100,
      1
    ),
    ' %'
  ) AS ratio
FROM
  clean_weekly_sales
GROUP BY
  1,
  2,
  3
ORDER BY
  1,
  2,
  3;
``` 
	
#### Result set:

*Sample result:

| calendar_year | month_number | platform | total_sales   | ratio  |
|---------------|--------------|----------|---------------|--------|
| 2018          | 3            | Retail   | 525,583,061   | 97.9%  |
| 2018          | 3            | Shopify  | 11,172,391    | 2.1%   |
| 2018          | 4            | Retail   | 2,617,369,077 | 97.9%  |
| 2018          | 4            | Shopify  | 55,435,570    | 2.1%   |
| 2018          | 5            | Retail   | 2,080,290,488 | 97.7%  |
| 2018          | 5            | Shopify  | 48,365,936    | 2.3%   |
| 2018          | 6            | Retail   | 2,061,128,568 | 97.8%  |
| 2018          | 6            | Shopify  | 47,323,635    | 2.2%   |
| 2018          | 7            | Retail   | 2,646,368,290 | 97.8%  |
| 2018          | 7            | Shopify  | 60,830,182    | 2.2%   |
| 2018          | 8            | Retail   | 2,140,297,292 | 97.7%  |
| 2018          | 8            | Shopify  | 50,244,975    | 2.3%   |

***

###  7. What is the percentage of sales by demographic for each year in the dataset?

```sql
SELECT
  calendar_year,
  demographic,
  SUM(sales) total_sales,
  CONCAT(
    ROUND(
      SUM(sales) / SUM(SUM(sales)) OVER (
        PARTITION BY
          calendar_year
      ) * 100,
      1
    ),
    ' %'
  ) AS ratio
FROM
  clean_weekly_sales
GROUP BY
  1,
  2
ORDER BY
  1,
  2;
``` 
	
#### Result set:

| calendar_year | demographic | total_sales    | ratio  |
|---------------|-------------|----------------|--------|
| 2018          | Couples     | 3,402,388,688  | 26.4%  |
| 2018          | Families    | 4,125,558,033  | 32.0%  |
| 2018          | unknown     | 5,369,434,106  | 41.6%  |
| 2019          | Couples     | 3,749,251,935  | 27.3%  |
| 2019          | Families    | 4,463,918,344  | 32.5%  |
| 2019          | unknown     | 5,532,862,221  | 40.3%  |
| 2020          | Couples     | 4,049,566,928  | 28.7%  |
| 2020          | Families    | 4,614,338,065  | 32.7%  |
| 2020          | unknown     | 5,436,315,907  | 38.6%  |

***

###  8. Which age_band and demographic values contribute the most to Retail sales?

- If you would take age_band and demographic seperatly

- Then for age_band:

```sql
SELECT
  age_band,
  SUM(sales) revenue
FROM
  clean_weekly_sales
WHERE
  platform = 'retail'
GROUP BY
  1
ORDER BY
  2 DESC;
``` 
	
#### Result set:

| age_band     | revenue        |
|--------------|----------------|
| unknown      | 16,067,285,533 |
| Retirees     | 13,005,266,930 |
| Middle Aged  | 6,208,251,884  |
| Young Adults | 4,373,812,090  |


- For Demographic:

```sql
SELECT
  demographic,
  SUM(sales) revenue
FROM
  clean_weekly_sales
WHERE
  platform = 'retail'
GROUP BY
  1
ORDER BY
  2 DESC;
``` 
	
#### Result set:

| demographic | revenue        |
|-------------|----------------|
| unknown     | 16,067,285,533 |
| Families    | 12,759,667,763 |
| Couples     | 10,827,663,141 |

- If both at the same time

```sql
SELECT
  age_band,
  demographic,
  SUM(sales) revenue
FROM
  clean_weekly_sales
WHERE
  platform = 'retail'
GROUP BY
  1,
  2
ORDER BY
  3 DESC;
```
#### Result set:

### Total Revenue by Age Band and Demographic

| age_band     | demographic | revenue        |
|--------------|-------------|----------------|
| unknown      | unknown     | 16,067,285,533 |
| Retirees     | Families    | 6,634,686,916  |
| Retirees     | Couples     | 6,370,580,014  |
| Middle Aged  | Families    | 4,354,091,554  |
| Young Adults | Couples     | 2,602,922,797  |
| Middle Aged  | Couples     | 1,854,160,330  |
| Young Adults | Families    | 1,770,889,293  |

***

###  9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

```sql
SELECT
  platform,
  calendar_year,
  SUM(sales) / SUM(transactions) AS not_using_avg_transaction,
  AVG(avg_transaction) AS using_avg_transaction
FROM
  clean_weekly_sales
GROUP BY
  2,
  1
ORDER BY
  1,
  2;
``` 
	
#### Result set:

| platform | calendar_year | not_using_avg_transaction | using_avg_transaction |
|----------|---------------|---------------------------|-----------------------|
| Retail   | 2018          | 36.56                     | 42.91                 |
| Retail   | 2019          | 36.83                     | 41.97                 |
| Retail   | 2020          | 36.56                     | 40.64                 |
| Shopify  | 2018          | 192.48                    | 188.28                |
| Shopify  | 2019          | 183.36                    | 177.56                |
| Shopify  | 2020          | 179.03                    | 174.87                |

- In this result the not_using_avg_transaction is far different from using avg_transaction. In this case I would use the sum(sales) / sum (transactions) for better accuracy

***