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
            'unknown') AS age_band,
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
;
-- In this result the not_using_avg_transaction is far different from using avg_transaction. In this case I would use the sum(sales) / sum (transactions) for better accuracy

-- 3. Before & After Analysis
-- This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
-- Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
-- We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before
-- Using this analysis approach - answer the following questions:

--     What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
select distinct(week_date), abs(round(datediff(week_date,'2020-06-15')/7)) as week_diff from clean_weekly_sales
where abs(round(datediff(week_date,'2020-06-15')/7)) <= 4
order by 1 asc
;
-- Since our dataset is weekly based, and the week 2020-06-15 is the base line, then the 4 weeks after the change should be from 2020-06-15 to 2020-07-06.
-- And for 4 weeks before the change should be from 2020-05-18 upto 2020-06-8 
SELECT 
    sales_4_weeks_bfr, sales_4_weeks_aft, concat(round((sales_4_weeks_aft/sales_4_weeks_bfr - 1)*100,2)," %") changes_compare_to_before
FROM
    (SELECT 
        SUM(sales) sales_4_weeks_bfr
    FROM
        clean_weekly_sales
    WHERE
        ROUND(DATEDIFF(week_date, '2020-06-15') / 7) between -4 and -1
            ) a
        CROSS JOIN
    (SELECT 
        SUM(sales) sales_4_weeks_aft
    FROM
        clean_weekly_sales
    WHERE
       ROUND(DATEDIFF(week_date, '2020-06-15') / 7) between 0 and 3
            ) b
;
-- The sales result for 4 weeks after the change went down by -1.15%

--     What about the entire 12 weeks before and after?
SELECT 
    sales_12_weeks_bfr, sales_12_weeks_aft, concat(round((sales_12_weeks_aft/sales_12_weeks_bfr - 1)*100,2)," %") changes_compare_to_before
FROM
    (SELECT 
        SUM(sales) sales_12_weeks_bfr
    FROM
        clean_weekly_sales
    WHERE
         ROUND(DATEDIFF(week_date, '2020-06-15') / 7) between -12 and -1
            ) a
        CROSS JOIN
    (SELECT 
        SUM(sales) sales_12_weeks_aft
    FROM
        clean_weekly_sales
    WHERE
         ROUND(DATEDIFF(week_date, '2020-06-15') / 7) between 0 and 11
            ) b
;
-- Sales result from 12 weeks after the change went down by -2.14% !

--     How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
-- After doing halfway through, I realized i can just use the week_number and still delivered the same result
select distinct(week_number) from clean_weekly_sales
where week_date = '2020-06-15'
;
-- '2020-06-15' is week 25
-- For the 4 weeks before, I can just query the result from week_number 21 to 24 and 4 weeks after from week_number 25 - 28
-- 12 weeks before is week_number 13 - 24 and 12 weeks after is week_number 25 - 36
select calendar_year,
sum(case when week_number between 21 and 24 then sales else 0 end) 4_wk_bf,
sum(case when week_number between 25 and 28 then sales else 0 end) 4_wk_af,
sum(case when week_number between 13 and 24 then sales else 0 end) 12_wk_bf,
sum(case when week_number between 25 and 36 then sales else 0 end) 12_wk_af
from 
clean_weekly_sales
group by 1
;
-- In 2019 , the 4 weeks period shows a 0.10% increment in sales, while the 12 weeks period showed a -0.30% decreasement in sales
-- In 2018, the 4 weeks period shows a 0.19% increment in sales, while the 12 weeks period showed a 1.63% increment in sales
-- Meaning in this metric, the drop in sales in 2020 is more severe than both 2018 and 2019 (-1.15% for 4 weeks and -2.14% for 12 weeks).

-- 4. Bonus Question

-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

--     region
--     platform
--     age_band
--     demographic
--     customer_type

with cte1 as (select 'region' as area, region, -- by region
sum(case when week_number between 13 and 24 then sales else 0 end) 12_wk_bf,
sum(case when week_number between 25 and 36 then sales else 0 end) 12_wk_af,
round(((sum(case when week_number between 25 and 36 then sales else 0 end)/sum(case when week_number between 13 and 24 then sales else 0 end))-1)*100,2) changes
 from clean_weekly_sales
where calendar_year = 2020
group by 2
order by 5 asc
limit 1)
,
cte2 as (
select 'platform' as area, platform, -- by platform
sum(case when week_number between 13 and 24 then sales else 0 end) 12_wk_bf,
sum(case when week_number between 25 and 36 then sales else 0 end) 12_wk_af,
round(((sum(case when week_number between 25 and 36 then sales else 0 end)/sum(case when week_number between 13 and 24 then sales else 0 end))-1)*100,2) changes
 from clean_weekly_sales
where calendar_year = 2020
group by 2
order by 5 asc
limit 1)
,
cte3 as (
select 'age_band' as area, age_band, -- by age_band
sum(case when week_number between 13 and 24 then sales else 0 end) 12_wk_bf,
sum(case when week_number between 25 and 36 then sales else 0 end) 12_wk_af,
round(((sum(case when week_number between 25 and 36 then sales else 0 end)/sum(case when week_number between 13 and 24 then sales else 0 end))-1)*100,2) changes
 from clean_weekly_sales
where calendar_year = 2020
group by 2
order by 5 asc
limit 1)
,
cte4 as (
select 'democraphic' as area, demographic, -- by demographic
sum(case when week_number between 13 and 24 then sales else 0 end) 12_wk_bf,
sum(case when week_number between 25 and 36 then sales else 0 end) 12_wk_af,
round(((sum(case when week_number between 25 and 36 then sales else 0 end)/sum(case when week_number between 13 and 24 then sales else 0 end))-1)*100,2) changes
 from clean_weekly_sales
where calendar_year = 2020
group by 2
order by 5 asc
limit 1)
,
cte5 as (
select 'customer_type' as area, customer_type, -- by customer_type
sum(case when week_number between 13 and 24 then sales else 0 end) 12_wk_bf,
sum(case when week_number between 25 and 36 then sales else 0 end) 12_wk_af,
round(((sum(case when week_number between 25 and 36 then sales else 0 end)/sum(case when week_number between 13 and 24 then sales else 0 end))-1)*100,2) changes
 from clean_weekly_sales
where calendar_year = 2020
group by 2
order by 5 asc
limit 1
)
select * from cte1
union all
select * from cte2
union all
select * from cte3
union all
select * from cte4
union all
select * from cte5
order by 5
;

-- Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?
-- I would recommend that the team fix the "unknown" problem in their data capturing process, as this group (demographic and age_band) represented a 40% of sales. By profiling their customers more accurately, better and more actionable insights could be derived.
-- The "guest" customer segment is the most affected by the packaging changes. I would recommend conducting a survey for this group of customers to determine the best packaging options for the next implementation.
-- The Retail platform is where the majority of revenue came from (over 96%). Even a small drop in sales could translate into millions in lost revenue. I would recommend conducting in-store surveys to capture shopper feedback.
-- The customer backlash during the 12-week period is clear, but Data Mart should follow up with another quarterly, semi-annual, and annual report to see if sales bounce back.