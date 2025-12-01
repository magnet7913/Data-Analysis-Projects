-- Case Study Questions

-- The following case study questions require some data cleaning steps before we start to unpack Danny’s key business questions in more depth.
-- 1. Data Cleansing Steps
-- In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
--     Convert the week_date to a DATE format
--     Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
--     Add a month_number with the calendar month for each week_date value as the 3rd column
--     Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
--     Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
-- segment 	age_band
-- 1 	Young Adults
-- 2 	Middle Aged
-- 3 or 4 	Retirees

--     Add a new demographic column using the following mapping for the first letter in the segment values:
-- segment 	demographic
-- C 	Couples
-- F 	Families

--     Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
--     Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record
drop table if exists clean_weekly_sales;
create table clean_weekly_sales as (
with cte as (SELECT 
    STR_TO_DATE(week_date, '%d/%m/%y') AS week_date,
    region,
    platform,
    CASE
        WHEN segment = 'null' THEN 'unknown'
        ELSE segment
    END AS segment,
    customer_type,
    transactions,
    sales

from weekly_sales
)
select 
week_date,
week(week_date,1) as week_number, -- So that week 1 contains Jan 1st
month(week_date) as month_number,
year(week_date) as calendar_year,
    region,
    platform,
    segment,
    COALESCE(ELT(FIELD(SUBSTRING(segment, 2, 1), '1', '2', '3', '4'),
                    'Young Adults',
                    'Middle Aged',
                    'Retirees',
                    'Retirees'),
            '') AS age_band,
    COALESCE(ELT(FIELD(SUBSTRING(segment, 1, 1), 'C', 'F'),
                    'Couples',
                    'Families'),
            'unknown') AS demographic,
    customer_type,
    transactions,
    sales,
    round(sales/transactions,2) as avg_transaction
 from cte)
;

-- 2. Data Exploration

--     What day of the week is used for each week_date value?
select weekday(week_date), count(*) from clean_weekly_sales
group by 1
;
-- 100% result is 0, then only MOnday is used for each week_date value

--     What range of week numbers are missing from the dataset?
select distinct(week_number) from clean_weekly_sales
;
-- The dataset ran continuously from week 12 to 35. Missing week 1 to 11 and week 36 to 53

--     How many total transactions were there for each year in the dataset?
select calendar_year, count(*) transaction_count from clean_weekly_sales
group by 1
;
--     What is the total sales for each region for each month?
select region, calendar_year, month_number, count(*) transaction_count from clean_weekly_sales
group by 1,2,3
order by 1,2,3
;

--     What is the total count of transactions for each platform
select platform, count(*) transaction_count from clean_weekly_sales
group by 1
order by 1
;

--     What is the percentage of sales for Retail vs Shopify for each month?
select calendar_year, month_number, platform, sum(sales) total_sales, concat(round(sum(sales) / sum(sum(sales)) over(partition by calendar_year, month_number) * 100,1),' %') as ratio
from clean_weekly_sales
group by 1,2,3
order by 1,2,3
;

--     What is the percentage of sales by demographic for each year in the dataset?
select calendar_year, demographic, sum(sales) total_sales, concat(round(sum(sales) / sum(sum(sales)) over(partition by calendar_year) * 100,1),' %') as ratio
from clean_weekly_sales
group by 1,2
order by 1,2
;

--     Which age_band and demographic values contribute the most to Retail sales?
-- If you would take age_band and demographic seperatly
-- Then for age_band
select age_band, sum(sales) revenue
from clean_weekly_sales
where platform = 'retail'
group by 1
order by 2 desc
;
-- For Demographic
select demographic, sum(sales) revenue
from clean_weekly_sales
where platform = 'retail'
group by 1
order by 2 desc
;
-- If both at the same time

select age_band,demographic, sum(sales) revenue
from clean_weekly_sales
where platform = 'retail'
group by 1,2
order by 3 desc
;

--     Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
select platform, calendar_year, sum(sales) / sum(transactions) as not_using_avg_transaction, avg(avg_transaction) as using_avg_transaction
from clean_weekly_sales
group by 2,1
order by 1,2
-- In this result the not_using_avg_transaction is far different from using avg_transaction. In this case I would use the sum(sales) / sum (transactions) for better accuracy

-- 3. Before & After Analysis
-- This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
-- Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
-- We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before
-- Using this analysis approach - answer the following questions:

--     What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
--     What about the entire 12 weeks before and after?
--     How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

-- 4. Bonus Question

-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

--     region
--     platform
--     age_band
--     demographic
--     customer_type

-- Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?