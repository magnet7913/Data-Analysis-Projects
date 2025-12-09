-- ## Case Study #8: Fresh Segments - Data Exploration and Cleansing

-- 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
update interest_metrics
set month_year = null;
alter table interest_metrics
modify month_year date;
update interest_metrics
set month_year = cast(concat(_year,'-',_month,'-','1') as date)
;

-- 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
select month, count_of_records from (select  month(month_year) month , case when month(month_year) is null then 1 else 2 end rn, count(*) count_of_records
from interest_metrics
group by 1,2) t
order by rn, 1 desc
;

-- 3. What do you think we should do with these null values in the fresh_segments.interest_metrics
-- Since the null values missed all 3 month, year and month_year value. There is no way to sort them into each month and keeping them around would create more issue when joining table and skew future ranking
-- I believe we should delete these entries
delete from interest_metrics
where month_year is null and _month is null and _year is null
;

-- 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
select count(distinct(interest_id)) metrics_not_in_map
from interest_metrics
where interest_id not in (select id from interest_map)
;

select count(distinct(id)) map_not_in_metrics
from interest_map
where id not in (select interest_id from interest_metrics)
;

-- 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
-- I believe technically this question asked how many time each id from interest_map appeared in interest_metrics
select id, count(*) total_count
from interest_map ma
left join interest_metrics me
on ma.id = me.interest_id
group by 1
;

-- 6. What sort of table join should we perform for our analysis and why? 
-- Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
-- Because there were interest that appeared in the interest_map and not in interest_metrics. The best idea was to LEFT JOIN from interest_map to interest_metrics
select *
from interest_map ma
left join interest_metrics me
on ma.id = me.interest_id
where interest_id = 21246
;
-- 7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?
-- Yes, these records are valid as long as the month and year value are the same, since month_year was forced to always be the 1st day of the month. Some records generated with in that month could result in month_year value is before the created_at date.
-- To check if any records are incorrect, i ran this query 
with cte as (
select *
from interest_map ma
left join interest_metrics me
on ma.id = me.interest_id)
select *
from cte 
where month(created_at) > cast(_month as unsigned)
and year(created_at) > cast(_year as unsigned) -- So we would be sure that the metrics was not created before the map
;
