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

-- Interest Analysis
--     Which interests have been present in all month_year dates in our dataset?
select min(month_year), max(month_year)
from interest_metrics
;
-- The Dataset ran from Jul 2018 to Aug 2019, meaning if an interests appeared in all month_year, its sum(month(month_year)) must be equal to 93
select interest_id, interest_name from (
select interest_id, sum(month(month_year)) total_month
from interest_metrics
group by 1) t
join interest_map ma
on t.interest_id = ma.id
where total_month = 93
;

--     Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
with t1 as (
select distinct(interest_id) iid, count(month_year) mcnt
from interest_metrics
group by 1),
t2 as (
select mcnt, count(iid) icnt
from t1
group by 1),
t3 as (
select mcnt, icnt, round ( sum(icnt) over (order by mcnt desc) / sum(icnt) over(),2) cumulative_perc
from t2
order by 1 desc)
select * from t3
where cumulative_perc >= 0.9
;
--     If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?
-- Lets get the list of interest with less 6 months appearance
with t1 as (select interest_id
from interest_metrics
group by 1
having count(distinct month_year) < 6) 
-- Then list of records to be removed
select count(*) records_to_remove
from interest_metrics
where interest_id in (select interest_id from t1)
;
--     Does this decision make sense to remove these data points from a business perspective? 
-- Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
with t1 as (select interest_id
from interest_metrics
group by 1
having count(distinct month_year) < 6),
t2 as (select month_year, count(distinct interest_id) existing_interest,
sum(case when interest_id in (select interest_id from t1) then 1 end) interest_to_remove
from interest_metrics
group by 1)
select *, round(interest_to_remove/existing_interest * 100,2) remove_ratio
from t2
;
-- The affected interest took a small portion of the record of each month, I think it it safe to remove them
with t1 as (select interest_id
from interest_metrics
group by 1
having count(distinct month_year) < 6)
delete from interest_metrics
where interest_id in (select interest_id
from t1)
;
--     After removing these interests - how many unique interests are there for each month?
select month_year, count(distinct(interest_id)) interest_count
from interest_metrics
group by 1
;

-- Segment Analysis
--     Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? 
-- Only use the maximum composition value for each interest but you must keep the corresponding month_year
with l10 as (select month_year, interest_id, composition, row_number() over (partition by month_year order by composition ) rn
from interest_metrics)
select month_year, interest_id, min(composition) composition
from l10 where rn <= 10
group by 1, 2
;
with h10 as (select month_year, interest_id, composition, row_number() over (partition by month_year order by composition desc) rn
from interest_metrics)
select month_year, interest_id, max(composition) composition
from h10 where rn <= 10
group by 1, 2
;

--     Which 5 interests had the lowest average ranking value?
select interest_name, avg(ranking) avg_ranking
from interest_metrics me
join interest_map ma
on me.interest_id = ma.id
group by 1
order by 2
limit 5
;

--     Which 5 interests had the largest standard deviation in their percentile_ranking value?
select interest_name, round(stddev_samp(percentile_ranking),2) std_dev
from interest_metrics me
join interest_map ma
on me.interest_id = ma.id
group by 1
order by 2 desc
limit 5
;
--     For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and its corresponding year_month value? Can you describe what is happening for these 5 interests?
with sd as (select interest_id, round(stddev_samp(percentile_ranking),2) std_dev
from interest_metrics me
group by 1
order by 2 desc
limit 5),
t1 as (select interest_name, month_year, percentile_ranking, row_number() over (partition by interest_name order by percentile_ranking) min_rn, row_number() over (partition by interest_name order by percentile_ranking desc) max_rn
from interest_metrics me 
join interest_map ma
on me.interest_id = ma.id
where interest_id in (select interest_id from sd)
group by 1,2,3)
select interest_name, month_year, percentile_ranking
from t1
where min_rn = 1 or max_rn = 1
order by 1,2
;
drop table avg_compo;
create temporary table avg_compo
as (select month_year, interest_id, round(composition/index_value,2) ac, row_number() over (partition by month_year order by  round(composition/index_value,2) desc) rn
from interest_metrics)
;
select * from avg_compo
;
-- 1. What is the top 10 interests by the average composition for each month?
select month_year, interest_name, ac 
from avg_compo ac
join interest_map ma
on ac.interest_id = ma.id
where rn <=10
order by 1
;
-- 2. For all of these top 10 interests - which interest appears the most often?
-- We would just need to add a cte to the previous query to get the answer
with t1 as (select month_year, interest_name, ac 
from avg_compo ac
join interest_map ma
on ac.interest_id = ma.id
where rn <=10)
select interest_name, count(*) appearance
from t1
group by 1 order by 2 desc
;
-- 3. What is the average of the average composition for the top 10 interests for each month?
select month_year, round(avg(ac),2) avg_avg_compo
from avg_compo
where rn <= 10
group by 1
;

-- 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
with t1 as (
select month_year, interest_name, ac, rn
from avg_compo ac 
join interest_map ma
on ac.interest_id = ma.id
),
t2 as (select month_year, interest_name, ac, lag(ac,1,0) over () l1ac,  lag(ac,2,0) over () l2ac, 
lag(interest_name,1,null) over () l1, 
lag(interest_name,2,null) over () l2
from t1
where rn = 1)
select month_year, interest_name, ac max_index_composition, round((ac+l1ac+l2ac)/3,2) `3_month_moving_avg`, concat(l1,": ",l1ac) `1_month_ago`, concat(l2,": ",l2ac) `2_month_ago`
from t2
having month_year between '2018-09-01' and '2019-08-01'
