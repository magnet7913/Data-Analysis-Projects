## Case Study #6: Clique Bait - Campaigns Analysis

Generate a table that has 1 single row for every unique visit_id record and has the following columns:

- user_id
- visit_id
- visit_start_time: the earliest event_time for each visit
- page_views: count of page views for each visit
- cart_adds: count of product cart add events for each visit
- purchase: 1/0 flag if a purchase event exists for each visit
- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
- impression: count of ad impressions for each visit
- click: count of ad clicks for each visit
- (Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added to the cart (hint: use the sequence_number)

```sql
WITH
  e AS ( -- extract visit_id, event_time, page_views, cart_adds, purchase, impression and click from events. user_id from users
    SELECT DISTINCT
      (visit_id),
      user_id,
      MIN(event_time) visit_start_time,
      SUM(
        CASE
          WHEN event_type = 1 THEN 1
          ELSE 0
        END
      ) page_views,
      SUM(
        CASE
          WHEN event_type = 2 THEN 1
          ELSE 0
        END
      ) cart_adds,
      MAX(
        CASE
          WHEN event_type = 3 THEN 1
          ELSE 0
        END
      ) purchase,
      SUM(
        CASE
          WHEN event_type = 4 THEN 1
          ELSE 0
        END
      ) impression,
      SUM(
        CASE
          WHEN event_type = 5 THEN 1
          ELSE 0
        END
      ) click
    FROM
      events e
      JOIN users u ON e.cookie_id = u.cookie_id
    GROUP BY
      1,
      2
  ),
  cn AS ( -- get campaign name
    SELECT
      visit_id,
      user_id,
      visit_start_time,
      page_views,
      cart_adds,
      purchase,
      campaign_name,
      impression,
      click
    FROM
      e
      LEFT JOIN campaign_identifier ci ON e.visit_start_time BETWEEN start_date AND end_date
  ),
  pl AS ( -- get list of all product added to cart per visit
    SELECT
      visit_id,
      page_name,
      sequence_number
    FROM
      events e
      JOIN page_hierarchy ph ON e.page_id = ph.page_id
    WHERE
      event_type = 2
    ORDER BY
      1,
      3
  ),
  cp AS ( -- combine the product list into 1 cell per visit
    SELECT
      visit_id,
      group_concat (
        page_name
        ORDER BY
          sequence_number,
          ','
      ) cart_products
    FROM
      pl
    GROUP BY
      1
  )
SELECT
  cn.*,
  cp.cart_products -- Final query to join all cte together
FROM
  cn
  LEFT JOIN cp ON cn.visit_id = cp.visit_id
ORDER BY
  3;
```
#### Sample Result set:

| visit_id | user_id | visit_start_time     | page_views | cart_adds | purchase | campaign_name                  | impression | click | cart_products                                      |
|----------|---------|----------------------|------------|-----------|----------|--------------------------------|------------|-------|----------------------------------------------------|
| 04ff73   | 124     | 2020-01-01 07:44:57  | 8          | 3         | 1        | BOGOF - Fishing For Compliments| 0          | 0     | Salmon,Kingfish,Abalone                            |
| 1c6058   | 391     | 2020-01-01 08:16:14  | 4          | 0         | 0        | BOGOF - Fishing For Compliments| 0          | 0     |                                                    |
| 73a060   | 146     | 2020-01-01 12:44:29  | 8          | 3         | 0        | BOGOF - Fishing For Compliments| 0          | 0     | Abalone,Lobster,Oyster                             |
| fac4c6   | 391     | 2020-01-01 13:30:17  | 1          | 0         | 0        | BOGOF - Fishing For Compliments| 0          | 0     |                                                    |
| 6e1589   | 379     | 2020-01-01 13:47:54  | 7          | 3         | 1        | BOGOF - Fishing For Compliments| 0          | 0     | Russian Caviar,Black Truffle,Crab                  |
| 02e178   | 379     | 2020-01-01 14:41:56  | 8          | 6         | 0        | BOGOF - Fishing For Compliments| 1          | 1     | Kingfish,Tuna,Russian Caviar,Black Truffle,Abalone,Lobster |
| 282384   | 124     | 2020-01-01 17:30:56  | 1          | 0         | 0        | BOGOF - Fishing For Compliments| 0          | 0     |                                                    |
| cdc2c2   | 146     | 2020-01-01 22:24:12  | 10         | 7         | 1        | BOGOF - Fishing For Compliments| 1          | 1     | Salmon,Tuna,Russian Caviar,Abalone,Lobster,Crab,Oyster |
| d599df   | 245     | 2020-01-02 00:12:24  | 1          | 0         | 0        | BOGOF - Fishing For Compliments| 0          | 0     |                                                    |
| a15368   | 271     | 2020-01-02 00:24:25  | 8          | 4         | 1        | BOGOF - Fishing For Compliments| 0          | 0     | Salmon,Kingfish,Tuna,Lobster                       |
| f3a4ae   | 275     | 2020-01-02 01:41:06  | 5          | 1         | 1        | BOGOF - Fishing For Compliments| 0          | 0     | Tuna                                               |
| 860ef7   | 271     | 2020-01-02 04:08:40  | 1          | 0         | 0        | BOGOF - Fishing For Compliments| 0          | 0     |                                                    |
| 6ea8f3   | 205     | 2020-01-02 04:45:44  | 9          | 7         | 1        | BOGOF - Fishing For Compliments| 1          | 1     | Salmon,Kingfish,Tuna,Russian Caviar,Black Truffle,Abalone,Crab |
| 8892a7   | 245     | 2020-01-02 05:33:08  | 6          | 1         | 1        | BOGOF - Fishing For Compliments| 0          | 0     | Kingfish                                           |
| 15fb7a   | 389     | 2020-01-02 05:47:03  | 6          | 1         | 1        | BOGOF - Fishing For Compliments| 0          | 0     | Tuna                                               |
| a3e6fa   | 401     | 2020-01-02 07:34:51  | 2          | 0         | 0        | BOGOF - Fishing For Compliments| 0          | 0     |                                                    |
| e818ff   | 275     | 2020-01-02 09:15:46  | 10         | 5         | 1        | BOGOF - Fishing For Compliments| 1          | 1     | Salmon,Tuna,Black Truffle,Abalone,Lobster          |
| 2e6d0a   | 159     | 2020-01-02 09:46:48  | 8          | 4         | 1        | BOGOF - Fishing For Compliments| 0          | 0     | Tuna,Black Truffle,Crab,Oyster                     |
| 9765eb   | 200     | 2020-01-02 09:47:58  | 1          | 0         | 0        | BOGOF - Fishing For Compliments| 0          | 0     |                                                    |
| 30ba8b   | 401     | 2020-01-02 10:17:15  | 7          | 4         | 1        | BOGOF - Fishing For Compliments| 1          | 1     | Kingfish,Abalone,Crab,Oyster                       |

***
