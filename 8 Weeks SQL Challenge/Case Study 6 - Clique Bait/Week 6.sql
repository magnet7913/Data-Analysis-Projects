   --  How many users are there?
   select count(distinct(user_id)) user_count
   from users
   ;
   
--     How many cookies does each user have on average?
select round(avg(cookies_count),2) avg_cookies from (select user_id, count(*) cookies_count
from users
group by 1) t
;

--     What is the unique number of visits by all users per month?
select  month(event_time) as month, count(distinct(visit_id)) unique_visit_count
from events
group by 1
order by 1
;

--     What is the number of events for each event type?
select event_type, count(*) count 
from events
group by 1
order by 1
;

--     What is the percentage of visits which have a purchase event?
-- With event_type 3 is Purchase, we would focus on event_type 3, and even if within a visit, a customer made 2 purchase, we would only count this as 1
select all_visit, visit_with_purchase, round(visit_with_purchase/all_visit*100,2) percentage from (
select count(distinct(visit_id)) all_visit,
count(distinct case when event_type = 3 then visit_id end) visit_with_purchase
from events) t
;

--     What is the percentage of visits which view the checkout page but do not have a purchase event?
-- We would count visit_id visited page_id = 12 (Checkout) but did not visit page_id = 13 (Confirmation)
with cte as (select visit_id, max(case when page_id = 12 then 1 else 0 end) as checkout, max(case when page_id = 13 then 1 else 0 end) as purchase
from events
group by 1)
select round((sum(checkout) - sum(purchase)) / sum(checkout) * 100,2) as no_purchase_after_checkout_percentage
from cte
;

--     What are the top 3 pages by number of views?
select ph.page_name, sum(case when event_type = 1 then 1 end) page_view
from events e
join page_hierarchy ph
on e.page_id = ph.page_id
group by 1
order by 2 desc
limit 3
;

--     What is the number of views and cart adds for each product category?
select distinct(product_category), sum(case when event_type = 1 then 1 end) page_views, sum(case when event_type = 2 then 1 end) add_to_cart_count 
from events e
left join page_hierarchy ph
on e.page_id = ph.page_id
where product_category is not null
group by 1
order by 2 desc
;

--     What are the top 3 products by purchases?
-- I would assume the cart is not shared between cookie_id of the same user
-- So a product is counted as purchased when with in a cookie_id, that product was added to cart, then there was as purchase event after
with atc as (select cookie_id, page_id, event_time
from events 
where event_type =2),
pc as (
select cookie_id, page_id, event_time
from events 
where event_type =3),
combine as (select distinct(atc.event_time), atc.cookie_id, atc.page_id
from atc
inner join pc 
on atc.cookie_id = pc.cookie_id
where pc.event_time > atc.event_time) -- to weed out the case that a product was added to cart after a purchase 
select ph.page_name product_name, count(*) purchase_count
from combine c
join page_hierarchy ph
on c.page_id = ph.page_id
group by 1
order by 2 desc
;

-- Using a single SQL query - create a new output table which has the following details:

--     How many times was each product viewed?
--     How many times was each product added to cart?
--     How many times was each product added to a cart but not purchased (abandoned)?
--     How many times was each product purchased?

-- For question 3 and 4, i would also do them on cookie_id basis
with p as ( -- get time_stamp of last purchase in a cookie_id
select cookie_id cid, max(event_time) pt from events
where event_type = 3 group by 1),
ac as ( -- set the list of all add_to_cart event
select cookie_id cid,page_id pid, event_time et from events
where event_type = 2),
acc as ( -- get the add_to_cart count per page_id
select pid, count(*) cart_add from ac group by 1),
vc as ( -- get the pageview count per page_id
select pid, count(*) views from (
select cookie_id cid,page_id pid, event_time et from events
where event_type = 1) t group by 1
),
cb as ( -- combine both p and ac for later querries
select ac.*, pt from ac
left join p on
ac.cid = p.cid),
apc as ( -- get product added then purchased
select pid,count(*) purchased from cb
where et < pt
group by 1),
ab as ( -- get product added but abandoned
select pid,count(*) abandoned from cb
where pt is null
group by 1)
select  ph.page_name, views, cart_add, purchased, abandoned from acc
join vc on acc.pid = vc.pid
join apc on acc.pid = apc.pid
join ab on acc.pid = ab.pid
join page_hierarchy ph on acc.pid = ph.page_id
order by acc.pid
;
-- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.
-- This could be done by simply change the final query from page_name to product_category and sum other metric
with p as ( -- get time_stamp of last purchase in a cookie_id
select cookie_id cid, max(event_time) pt from events
where event_type = 3 group by 1),
ac as ( -- set the list of all add_to_cart event
select cookie_id cid,page_id pid, event_time et from events
where event_type = 2),
acc as ( -- get the add_to_cart count per page_id
select pid, count(*) cart_add from ac group by 1),
vc as ( -- get the pageview count per page_id
select pid, count(*) views from (
select cookie_id cid,page_id pid, event_time et from events
where event_type = 1) t group by 1
),
cb as ( -- combine both p and ac for later querries
select ac.*, pt from ac
left join p on
ac.cid = p.cid),
apc as ( -- get product added then purchased
select pid,count(*) purchased from cb
where et < pt
group by 1),
ab as ( -- get product added but abandoned
select pid,count(*) abandoned from cb
where pt is null
group by 1)
select  ph.product_category, sum(views), sum(cart_add), sum(purchased), sum(abandoned) from acc
join vc on acc.pid = vc.pid
join apc on acc.pid = apc.pid
join ab on acc.pid = ab.pid
join page_hierarchy ph on acc.pid = ph.page_id
group by 1
order by 1
;
-- Use your 2 new output tables - answer the following questions:
with p as ( -- get time_stamp of last purchase in a cookie_id
select cookie_id cid, max(event_time) pt from events
where event_type = 3 group by 1),
ac as ( -- set the list of all add_to_cart event
select cookie_id cid,page_id pid, event_time et from events
where event_type = 2),
acc as ( -- get the add_to_cart count per page_id
select pid, count(*) cart_add from ac group by 1),
vc as ( -- get the pageview count per page_id
select pid, count(*) views from (
select cookie_id cid,page_id pid, event_time et from events
where event_type = 1) t group by 1
),
cb as ( -- combine both p and ac for later querries
select ac.*, pt from ac
left join p on
ac.cid = p.cid),
apc as ( -- get product added then purchased
select pid,count(*) purchased from cb
where et < pt
group by 1),
ab as ( -- get product added but abandoned
select pid,count(*) abandoned from cb
where pt is null
group by 1),
final as (select  ph.page_name product, views, cart_add, purchased, abandoned from acc
join vc on acc.pid = vc.pid
join apc on acc.pid = apc.pid
join ab on acc.pid = ab.pid
join page_hierarchy ph on acc.pid = ph.page_id
)
select round(sum(purchased)/sum(cart_add)*100,2) conversion_rate
from final
;
select product, round(abandoned/cart_add*100,2) abandoned_rate
from final
order by 2 desc
limit 1
;
select product, round(purchased/views*100,2) view_purchase_ratio
from final
order by 2 desc
limit 1
;
select round(sum(cart_add)/sum(views)*100,2) conversion_rate
from final
;

--     Which product had the most views, cart adds and purchases?
--	Lobster had the most cart_add and purchased
--  Oyster had the most views

--     Which product was most likely to be abandoned?
select product, round(abandoned/cart_add*100,2) abandoned_rate
from final
order by 2 desc
limit 1
;
--  The product was most likely to be abandoned is Russian Caviar at 15.01% abandoned rate

--     Which product had the highest view to purchase percentage?
select product, round(purchased/views*100,2) view_purchase_ratio
from final
order by 2 desc
limit 1
;
-- The product had the highest view to purchase percentage is Lobster at 51.26%

--     What is the average conversion rate from view to cart add?
select round(sum(cart_add)/sum(views)*100,2) conversion_rate
from final
;
-- The conversion rate was 60.93%

--     What is the average conversion rate from cart add to purchase?
select round(sum(purchased)/sum(cart_add)*100,2) conversion_rate
from final
-- The conversion rate was 81.15%
;

-- 3. Campaigns Analysis

-- Generate a table that has 1 single row for every unique visit_id record and has the following columns:

--     user_id
--     visit_id
--     visit_start_time: the earliest event_time for each visit
--     page_views: count of page views for each visit
--     cart_adds: count of product cart add events for each visit
--     purchase: 1/0 flag if a purchase event exists for each visit
--     campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
--     impression: count of ad impressions for each visit
--     click: count of ad clicks for each visit
--     (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)

with e as ( -- extract visit_id, event_time, page_views, cart_adds, purchase, impression and click from events. user_id from users
select distinct(visit_id), user_id, 
min(event_time) visit_start_time, 
sum(case when event_type = 1 then 1 else 0 end) page_views, 
sum(case when event_type = 2 then 1 else 0 end) cart_adds,
max(case when event_type = 3 then 1 else 0 end) purchase,

sum(case when event_type = 4 then 1 else 0 end) impression,
sum(case when event_type = 5 then 1 else 0 end) click

from events e
join users u
on e.cookie_id = u.cookie_id
group by 1,2),
cn as ( -- get campaign name
select visit_id,user_id,visit_start_time, page_views, cart_adds,purchase,campaign_name,impression,click
from e
left join campaign_identifier ci
on e.visit_start_time between start_date and end_date),
pl as ( -- get list of all product added to cart per visit
select visit_id, page_name, sequence_number
from events e
join page_hierarchy ph
on e.page_id = ph.page_id
where event_type = 2
order by 1,3),
cp as ( -- combine the product list into 1 cell per visit
select visit_id, group_concat(page_name order by sequence_number,',') cart_products
from pl
group by 1)
select cn.*, cp.cart_products -- Final query to join all cte together
from cn
left join cp on cn.visit_id = cp.visit_id
order by 3
;
 