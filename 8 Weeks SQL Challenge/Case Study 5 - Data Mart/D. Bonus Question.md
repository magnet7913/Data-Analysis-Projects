## Case Study #5: Data Mart - Bonus Question

Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

+ region
+ platform
+ age_band
+ demographic
+ customer_type

Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

###  1. Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

- I would query 5 times for each area to find the most negative impact in each area then combine them into one table

```sql
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
```

#### Result set:

| area          | category | 12_wk_before  | 12_wk_after   | change   |
|---------------|----------|---------------|---------------|----------|
| age_band      | unknown  | 2,764,354,464 | 2,671,961,443 | -3.34%   |
| demographic   | unknown  | 2,764,354,464 | 2,671,961,443 | -3.34%   |
| region        | ASIA     | 1,637,244,466 | 1,583,807,621 | -3.26%   |
| customer_type | Guest    | 2,573,436,301 | 2,496,233,635 | -3.00%   |
| platform      | Retail   | 6,906,861,113 | 6,738,777,279 | -2.43%   |

***

###  2. Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

- I would recommend that the team fix the "unknown" problem in their data capturing process, as this group (demographic and age_band) represented a 40% of sales. By profiling their customers more accurately, better and more actionable insights could be derived.

- The "guest" customer segment is the most affected by the packaging changes. I would recommend conducting a survey for this group of customers to determine the best packaging options for the next implementation.

- The Retail platform is where the majority of revenue came from (over 96%). Even a small drop in sales could translate into millions in lost revenue. I would recommend conducting in-store surveys to capture shopper feedback.

- The customer backlash during the 12-week period is clear, but Data Mart should follow up with another quarterly, semi-annual, and annual report to see if sales bounce back.