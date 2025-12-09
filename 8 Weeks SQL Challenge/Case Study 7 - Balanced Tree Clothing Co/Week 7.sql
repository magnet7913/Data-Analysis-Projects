-- High Level Sales Analysis

--     What was the total quantity sold for all products?
select product_name, sum(qty) qty_sold from sales s
join product_details pd
on s.prod_id = pd.product_id
group by 1
order by 2 desc
;

--     What is the total generated revenue for all products before discounts?
select product_name, sum(qty*s.price) revenue_bfr_discount from sales s
join product_details pd
on s.prod_id = pd.product_id
group by 1
order by 2 desc
;

--     What was the total discount amount for all products?
select round(sum(qty*s.price*(discount/100)),2) total_discounted from sales s
join product_details pd
on s.prod_id = pd.product_id
;

-- Transaction Analysis
--     How many unique transactions were there?
select count(distinct(txn_id)) unique_transaction
from sales
;

--     What is the average unique products purchased in each transaction?
select round(avg(up),2) unique_products_purchased from (
select distinct(txn_id), count(*) up
from sales
group by 1) t
;

--     What are the 25th, 50th and 75th percentile values for the revenue per transaction?
select percentile*100 percentile,round(avg(distinct(revenue))) revenue from (select txn_id, sum(qty * price) revenue, round(percent_rank() over (order by sum(qty * price)),2) percentile
from sales
group by 1
order by 2 desc) t
where percentile in (.25,.5,.75)
group by 1
;
--     What is the average discount value per transaction?
with sv as (
select txn_id, sum(qty*price*(discount/100)) discounted
from sales
group by 1)
select round(avg(discounted),2) discounted
from sv
;
--     What is the percentage split of all transactions for members vs non-members?
with check_member as (select count(distinct(case when member = 1 then txn_id end))as member_transaction,
count(distinct(case when member = 0 then txn_id end)) as non_member_transaction
from sales
)
select member_transaction, 
round(member_transaction/(member_transaction+non_member_transaction)*100,2) member_percent, 
non_member_transaction, 
round(non_member_transaction/(member_transaction+non_member_transaction)*100,2) non_member_percent
from check_member 
;
--     What is the average revenue for member transactions and non-member transactions?
-- I would calculate revenue after Discount
with check_member_revenue as (select txn_id, sum(case when member = 1 then qty*price*(1-discount/100) end) as member_transaction,
sum(case when member = 0 then qty*price*(1-discount/100) end) as non_member_transaction
from sales
group by 1
) 
select round(avg(member_transaction),2) member_transaction, round(avg(non_member_transaction),2) non_member_transaction 
from check_member_revenue
;

-- Product Analysis

--     What are the top 3 products by total revenue before discount?
select product_name, sum(qty*s.price) revenue
from sales s
join product_details pd
on s.prod_id = pd.product_id
group by 1
order by 2 desc
limit 3
;

--     What is the total quantity, revenue and discount for each segment?
select segment_name, sum(qty) total_quantity, sum(qty*s.price) total_raw_revenue, round(sum(qty*s.price*(1-discount/100)),2) total_discounted
from sales s
join product_details pd
on s.prod_id = pd.product_id
group by 1
;

--     What is the top selling product for each segment?
-- I'll rank the product by raw revenue for this question
with rn as (select segment_name, product_name, sum(qty*s.price) total_raw_revenue, rank() over (partition by segment_name order by sum(qty*s.price) desc) rnk
from sales s
join product_details pd
on s.prod_id = pd.product_id
group by 1,2)
select segment_name, product_name, total_raw_revenue
from rn 
where rnk = 1
;

--     What is the total quantity, revenue and discount for each category?
select category_name, sum(qty) total_quantity, sum(qty*s.price) total_raw_revenue, round(sum(qty*s.price*(1-discount/100)),2) total_discounted
from sales s
join product_details pd
on s.prod_id = pd.product_id
group by 1
;

--     What is the top selling product for each category?
-- I'll rank the product by raw revenue for this question
with rn as (select category_name, product_name, sum(qty*s.price) total_raw_revenue, rank() over (partition by category_name order by sum(qty*s.price) desc) rnk
from sales s
join product_details pd
on s.prod_id = pd.product_id
group by 1,2)
select category_name, product_name, total_raw_revenue
from rn 
where rnk = 1
;

--     What is the percentage split of revenue by product for each segment?
with raw_revenue as (select segment_name, product_name, sum(qty*s.price) total_raw_revenue
from sales s
join product_details pd
on s.prod_id = pd.product_id
group by 1,2)
select segment_name, 
product_name, 
round(total_raw_revenue/sum(total_raw_revenue) over (partition by segment_name)*100,2) percentage_split
from raw_revenue
;

--     What is the percentage split of revenue by segment for each category?
with raw_revenue as (select category_name, segment_name, sum(qty*s.price) total_raw_revenue
from sales s
join product_details pd
on s.prod_id = pd.product_id
group by 1,2)
select category_name, 
segment_name,
round(total_raw_revenue/sum(total_raw_revenue) over (partition by category_name)*100,2) percentage_split
from raw_revenue
;

--     What is the percentage split of total revenue by category?
with raw_revenue as (select category_name, sum(qty*s.price) total_raw_revenue
from sales s
join product_details pd
on s.prod_id = pd.product_id
group by 1)
select category_name, 
round(total_raw_revenue/sum(total_raw_revenue) over()*100,2) percentage_split
from raw_revenue
;

--     What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
with t1 as (
select product_name, count(*) appearance
from sales s
join product_details pd
on pd.product_id = s.prod_id
group by 1),
t2 as (
select count(distinct(txn_id)) total
from sales)
select product_name, round(appearance / total * 100, 2 ) penetration_rate
from t1 join t2
order by 2 desc
;

--     What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
-- I believe this could be dont by getting all possible combinations of 3 products together then group them by txn_id and count how many time each combination appeared
with p as (select txn_id tid, product_name pn
from sales s
join product_details pd
on s.prod_id = pd.product_id
),
combine as (select p.pn pn1, p1.pn pn2, p2.pn pn3, count(*) tpt, row_number() over (order by count(*) desc) rn
from p
join p p1 on p.tid = p1.tid
and p.pn != p1.pn
and p.pn < p1.pn
join p p2 on p.tid = p2.tid
and p.pn != p2.pn
and p1.pn != p2.pn
and p.pn < p2.pn
and p1.pn < p2.pn
group by 1,2,3)
select pn1 product_1, pn2 product_2, pn3 product_3, tpt times_purchased_together
from combine 
where rn = 1
;

-- Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.
-- Hint: you may want to consider using a recursive CTE to solve this problem!

-- Recursive CTE would be overkilled for this question. Just join the table with itself a few times would be enough :)
SELECT 
    product_id,
    price,
    concat(ph2.level_text," ",ph.level_text," - ",ph3.level_text) product_name,
    ph3.id category_id,
    ph2.id segment_id,
    ph.id style_id,
    ph3.level_text category_name,
     ph2.level_text segment_name,
    ph.level_text style_name
FROM
    product_prices pp
        LEFT JOIN
    product_hierarchy ph ON pp.id = ph.id
        LEFT JOIN
    product_hierarchy ph2 ON ph.parent_id = ph2.id
        LEFT JOIN
    product_hierarchy ph3 ON ph2.parent_id = ph3.id
