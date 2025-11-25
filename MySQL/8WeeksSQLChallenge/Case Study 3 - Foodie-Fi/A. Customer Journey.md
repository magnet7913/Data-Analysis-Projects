## Case Study #3: Foodie-Fi - Customer Journey

Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

***

To get the sample group:

```sql
SELECT
  s.*
FROM
  subscriptions s
  JOIN (
    SELECT DISTINCT
      (customer_id)
    FROM
      subscriptions
    ORDER BY
      RAND ()
    LIMIT
      8
  ) t ON t.customer_id = s.customer_id
ORDER BY
  1,
  2,
  3;
```

| customer_id | plan_id | start_date  |
|-------------|---------|-------------|
| 280         | 0       | 2020-06-17  |
| 280         | 1       | 2020-06-24  |
| 280         | 2       | 2020-10-28  |
| 280         | 4       | 2021-02-23  |
| 409         | 0       | 2020-09-02  |
| 409         | 1       | 2020-09-09  |
| 409         | 2       | 2021-01-29  |
| 480         | 0       | 2020-10-05  |
| 480         | 1       | 2020-10-12  |
| 480         | 3       | 2021-02-10  |
| 605         | 0       | 2020-09-23  |
| 605         | 3       | 2020-09-30  |
| 612         | 0       | 2020-11-14  |
| 612         | 4       | 2020-11-21  |
| 729         | 0       | 2020-04-03  |
| 729         | 1       | 2020-04-10  |
| 729         | 2       | 2020-08-17  |
| 917         | 0       | 2020-07-07  |
| 917         | 1       | 2020-07-14  |
| 917         | 3       | 2020-10-10  |
| 949         | 0       | 2020-10-07  |
| 949         | 2       | 2020-10-14  |

Here are short onboarding journey descriptions for each customer (accurate to the data provided):

### Customer 280
- Started free trial on 2020-06-17 and subscribed to the basic monthly plan at the end of the 7-day trial on 2020-06-24. 
- Upgraded to pro monthly on 2020-10-28. 
- Cancelled their subscription (churned) on 2021-02-23.

### Customer 409
- Started free trial on 2020-09-02 and subscribed to the basic monthly plan after 7 days on 2020-09-09. 
- Upgraded to pro monthly on 2021-01-29. 
- Still active on pro monthly at the end of the dataset.

### Customer 480
- Started free trial on 2020-10-05 and subscribed to the basic monthly plan after 7 days on 2020-10-12. 
- Upgraded directly to pro annual on 2021-02-10. 
- Still active on pro annual at the end of the dataset.

### Customer 605
- Started free trial on 2020-09-23 and upgraded directly to pro annual after just 7 days on 2020-09-30. 
- Still active on pro annual at the end of the dataset.

### Customer 612
- Started free trial on 2020-11-14 
- Cancelled (churned) after exactly 7 days on 2020-11-21 without ever subscribing to a paid plan.

### Customer 729
- Started free trial on 2020-04-03 and subscribed to the basic monthly plan after 7 days on 2020-04-10. 
- Upgraded to pro monthly on 2020-08-17. 
- Still active on pro monthly at the end of the dataset.

### Customer 917
- Started free trial on 2020-07-07 and subscribed to the basic monthly plan after 7 days on 2020-07-14. 
- Upgraded to pro annual on 2020-10-10. 
- Still active on pro annual at the end of the dataset.

### Customer 949
- Started free trial on 2020-10-07 and upgraded directly to pro monthly after just 7 days on 2020-10-14. 
- Still active on pro monthly at the end of the dataset.

***