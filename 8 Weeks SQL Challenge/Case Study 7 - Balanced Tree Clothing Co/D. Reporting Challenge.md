## Case Study #7: Balanced Tree Clothing Co. - Reporting Challenge

Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)

***

- I believe this question meant we just need to create a temporary table of the month the team would like to calculate the result for.

```sql
CREATE TEMP TABLE sales_monthly AS (
SELECT
  *
FROM
  sales
WHERE
  MONTH (start_txn_time) = 2
  AND YEAR (start_txn_time) = 2021
)
```

The reporting team just need to change the `month` and/or `year` value to get that month report.
All other queries from this Case Study, instead of refering to the `sales` table would be changed to `sales_monthly` temporary table instead.