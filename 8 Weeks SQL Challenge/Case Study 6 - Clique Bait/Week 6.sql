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
limit 3


-- Using a single SQL query - create a new output table which has the following details:

--     How many times was each product viewed?
--     How many times was each product added to cart?
--     How many times was each product added to a cart but not purchased (abandoned)?
--     How many times was each product purchased?

-- Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

-- Use your 2 new output tables - answer the following questions:

--     Which product had the most views, cart adds and purchases?
--     Which product was most likely to be abandoned?
--     Which product had the highest view to purchase percentage?
--     What is the average conversion rate from view to cart add?
--     What is the average conversion rate from cart add to purchase?
