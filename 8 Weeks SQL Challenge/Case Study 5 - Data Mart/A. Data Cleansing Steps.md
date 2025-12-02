## Case Study #5: Data Mart - Data Cleansing Steps

In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

- Convert the week_date to a DATE format
- Add a **week_number** as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
- Add a **month_number** with the calendar month for each week_date value as the 3rd column
- Add a **calendar_year** column as the 4th column containing either 2018, 2019 or 2020 values
- Add a new column called **age_band** after the original segment column using the following mapping on the number inside the segment value

| segment | age_band     |
|---------|--------------|
| 1       | Young Adults |
| 2       | Middle Aged  |
| 3       | Retirees     |
| 4       | Retirees     |

- Add a new **demographic** column using the following mapping for the first letter in the segment values

| segment | demographic |
|---------|-------------|
| C       | Couples     |
| F       | Families    |

- Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
- Generate a new **avg_transaction** column as the sales value divided by transactions rounded to 2 decimal places for each record

***

```sql
CREATE TABLE clean_weekly_sales AS (
  WITH
    cte AS (
      SELECT
        STR_TO_DATE (week_date, '%d/%m/%y') AS week_date,
        region,
        platform,
        CASE
          WHEN segment = 'null' THEN 'unknown'
          ELSE segment
        END AS segment,
        customer_type,
        transactions,
        sales
      FROM
        weekly_sales
    )
  SELECT
    week_date,
    week (week_date, 1) AS week_number, -- So that week 1 contains Jan 1st
    MONTH (week_date) AS month_number,
    YEAR (week_date) AS calendar_year,
    region,
    platform,
    segment,
    COALESCE(
      ELT (
        FIELD (SUBSTRING(segment, 2, 1), '1', '2', '3', '4'),
        'Young Adults',
        'Middle Aged',
        'Retirees',
        'Retirees'
      ),
      'unknown'
    ) AS age_band,
    COALESCE(
      ELT (
        FIELD (SUBSTRING(segment, 1, 1), 'C', 'F'),
        'Couples',
        'Families'
      ),
      'unknown'
    ) AS demographic,
    customer_type,
    transactions,
    sales,
    ROUND(sales / transactions, 2) AS avg_transaction
  FROM
    cte
);
```

***

#### Result set:

| week_date  | week | month | year | region   | platform | segment | age_band     | demographic | customer_type | transactions | sales      | avg_transaction_value |
|------------|------|-------|------|----------|----------|---------|--------------|-------------|---------------|--------------|------------|-----------------------|
| 2020-08-31 | 36   | 8     | 2020 | ASIA     | Retail   | C3      | Retirees     | Couples     | New           | 120631       | 3656163    | 30.31                 |
| 2020-08-31 | 36   | 8     | 2020 | ASIA     | Retail   | F1      | Young Adults | Families    | New           | 31574        | 996575     | 31.56                 |
| 2020-08-31 |36   | 8     | 2020 | USA      | Retail   | unknown | unknown      | unknown     | Guest         | 529151       | 16509610   | 31.20                 |
| 2020-08-31 |36   | 8     | 2020 | EUROPE   | Retail   | C1      | Young Adults | Couples     | New           | 4517         | 141942     | 31.42                 |
| 2020-08-31 |36   | 8     | 2020 | AFRICA   | Retail   | C2      | Middle Aged  | Couples     | New           | 58046        | 1758388    | 30.29                 |
| 2020-08-31 |36   | 8     | 2020 | CANADA   | Shopify  | F2      | Middle Aged  | Families    | Existing      | 1336         | 243878     | 182.54                |
| 2020-08-31 |36   | 8     | 2020 | AFRICA   | Shopify  | F3      | Retirees     | Families    | Existing      | 2514         | 519502     | 206.64                |
| 2020-08-31 |36   | 8     | 2020 | ASIA     | Shopify  | F1      | Young Adults | Families    | Existing      | 2158         | 371417     | 172.11                |
| 2020-08-31 |36   | 8     | 2020 | AFRICA   | Shopify  | F2      | Middle Aged  | Families    | New           | 318          | 49557      | 155.84                |
| 2020-08-31 |36   | 8     | 2020 | AFRICA   | Retail   | C3      | Retirees     | Couples     | New           | 111032       | 3888162    | 35.02                 |