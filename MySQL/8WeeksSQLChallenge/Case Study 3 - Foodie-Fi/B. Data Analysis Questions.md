# Case Study #3: Foodie-Fi - Data Analysis Questions

## Case Study Questions
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

***

###  1. How many customers has Foodie-Fi ever had?

```sql
SELECT
  COUNT(DISTINCT (customer_id)) AS customer_count
FROM
  subscriptions;
```

#### Result set:

| customer_count |
|----------------|
| 1000           |

***

###  2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

```sql
SELECT
  MONTH (
    CAST(DATE_FORMAT (start_date, '%Y-%m-01') AS DATE)
  ) AS MONTH,
  COUNT(*) AS trial_plan_count
FROM
  subscriptions
WHERE
  plan_id = 0
GROUP BY
  1
ORDER BY
  1;
```

#### Result set:

| month | trial_plan_count |
|-------|------------------|
| 1     | 88               |
| 2     | 68               |
| 3     | 94               |
| 4     | 81               |
| 5     | 88               |
| 6     | 79               |
| 7     | 89               |
| 8     | 88               |
| 9     | 87               |
| 10    | 79               |
| 11    | 75               |
| 12    | 84               |

***

###  3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

```sql
SELECT
  plan_id,
  COUNT(*) count
FROM
  subscriptions
WHERE
  YEAR (start_date) > 2020
GROUP BY
  1
ORDER BY
  1;
```

#### Result set:

### Current Subscription Status Distribution (as of end of dataset)

| plan_id | count |
|---------|-------|
| 1       | 8     |
| 2       | 60    |
| 3       | 63    |
| 4       | 71    |

***

###  4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

```sql
-- First I would like to confirm when a customer is churned, its the end of that customer_id, if the person subcribes again, a new customer_id would be issued:
SELECT
  *
FROM
  (
    SELECT
      *,
      ROW_NUMBER() OVER (
        PARTITION BY
          customer_id
        ORDER BY
          start_date DESC
      ) rn
    FROM
      subscriptions
  ) t
WHERE
  plan_id = 4
  AND rn > 1;
-- This query returned empty, then it the above statement is confirmed
SELECT
  COUNT(DISTINCT (customer_id)) total_customer,
  SUM(
    CASE
      WHEN plan_id = 4 THEN 1
      ELSE 0
    END
  ) AS churn_count,
  CONCAT(
    ROUND(
      SUM(
        CASE
          WHEN plan_id = 4 THEN 1
          ELSE 0
        END
      ) / COUNT(DISTINCT (customer_id)) * 100,
      1
    ),
    '%'
  ) AS churn_rate
FROM
  subscriptions;
```

#### Result set:

| total_customer | churn_count | churn_rate |
|----------------|-------------|------------|
| 1000           | 307         | 30.7%      |

***

###  5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

```sql
SELECT
  COUNT(DISTINCT (customer_id)) total_customer,
  SUM(
    CASE
      WHEN rn = 2
      AND plan_id = 4 THEN 1
      ELSE 0
    END
  ) AS churn_after_trial,
  CONCAT(
    ROUND(
      SUM(
        CASE
          WHEN rn = 2
          AND plan_id = 4 THEN 1
          ELSE 0
        END
      ) / COUNT(DISTINCT (customer_id)) * 100,
      0
    ),
    "%"
  ) AS churn_after_trial_rate
FROM
  (
    SELECT
      *,
      ROW_NUMBER() OVER (
        PARTITION BY
          customer_id
        ORDER BY
          start_date
      ) rn
    FROM
      subscriptions
  ) t;
```

#### Result set:

| total_customer | churn_after_trial | churn_after_trial_rate |
|----------------|-------------------|------------------------|
| 1000           | 92                | 9%                     |

***

###  6. What is the number and percentage of customer plans after their initial free trial?

```sql
SELECT
  plan_id,
  COUNT(*) AS amount,
  CONCAT(
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2),
    '%'
  ) AS percentage
FROM
  (
    SELECT
      plan_id,
      ROW_NUMBER() OVER (
        PARTITION BY
          customer_id
        ORDER BY
          start_date
      ) rn
    FROM
      subscriptions
  ) t
WHERE
  rn = 2
GROUP BY
  1;
```

#### Result set:

| plan_id | amount | percentage |
|---------|--------|------------|
| 1       | 546    | 54.60%     |
| 3       | 37     | 3.70%      |
| 2       | 325    | 32.50%     |
| 4       | 92     | 9.20%      |

***

###  7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```sql
SELECT
  plan_id,
  COUNT(*) total_sub,
  CONCAT(
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100),
    "%"
  ) AS percentage
FROM
  (
    SELECT
      *,
      ROW_NUMBER() OVER (
        PARTITION BY
          customer_id
        ORDER BY
          start_date DESC
      ) rn
    FROM
      subscriptions
    WHERE
      YEAR (start_date) < 2021
  ) t
WHERE
  rn = 1
GROUP BY
  1
ORDER BY
  1;
```

#### Result set:

| plan_id | total_sub | percentage |
|---------|-----------|------------|
| 0       | 19        | 2%         |
| 1       | 224       | 22%        |
| 2       | 326       | 33%        |
| 3       | 195       | 20%        |
| 4       | 236       | 24%        |

***

###  8. How many customers have upgraded to an annual plan in 2020?

```sql
SELECT
  COUNT(DISTINCT (customer_id)) total_annual_sub
FROM
  subscriptions
WHERE
  plan_id = 3
  AND YEAR (start_date) = 2020;
```

#### Result set:

| total_annual_sub |
|------------------|
| 195              |

***

###  9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

```sql
-- I assume we only take the one with annual plan into consideration
SELECT
  ROUND(AVG(days_till_annual_sub)) average_day_to_annual_plan
FROM
  (
    SELECT
      s1.customer_id,
      s1.start_date AS annual_sub_date,
      s2.start_date AS trial_date,
      datediff (s1.start_date, s2.start_date) AS days_till_annual_sub
    FROM
      subscriptions s1
      LEFT JOIN (
        SELECT
          customer_id,
          start_date
        FROM
          subscriptions
        WHERE
          plan_id = 0
      ) s2 ON s1.customer_id = s2.customer_id
    WHERE
      s1.plan_id = 3
  ) t;
```

#### Result set:

| average_day_to_annual_plan |
|----------------------------|
| 105                        |

***

###  10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

```sql
SELECT
  CONCAT((date_range - 1) * 30, '-', date_range * 30) AS date_range,
  COUNT(*) sub_count
FROM
  (
    SELECT
      s1.customer_id,
      s1.start_date AS annual_sub_date,
      s2.start_date AS trial_date,
      DATEDIFF (s1.start_date, s2.start_date) AS days_till_annual_sub,
      CEIL(DATEDIFF (s1.start_date, s2.start_date) / 30) date_range
    FROM
      subscriptions s1
      LEFT JOIN (
        SELECT
          customer_id,
          start_date
        FROM
          subscriptions
        WHERE
          plan_id = 0
      ) s2 ON s1.customer_id = s2.customer_id
    WHERE
      s1.plan_id = 3
  ) t
GROUP BY
  1
ORDER BY
  MIN((t.date_range - 1) * 30);
```

#### Result set:

| date_range | sub_count |
|------------|-----------|
| 0-30       | 49        |
| 30-60      | 24        |
| 60-90      | 34        |
| 90-120     | 35        |
| 120-150    | 42        |
| 150-180    | 36        |
| 180-210    | 26        |
| 210-240    | 4         |
| 240-270    | 5         |
| 270-300    | 1         |
| 300-330    | 1         |
| 330-360    | 1         |

***

###  11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
SELECT
  *
FROM
  (
    SELECT
      *,
      LAG(plan_id, 1, NULL) OVER (
        PARTITION BY
          customer_id
        ORDER BY
          start_date
      ) AS prev_plan
    FROM
      subscriptions
  ) t
WHERE
  plan_id = 1
  AND prev_plan = 2
```

#### Result set:

| customer_id | plan_id | start_date  | prev_plan |
|-------------|---------|-------------|-----------|
|             |         |             |           |

- The result was empty, therefore none of the customer downgraded from Pro monthly to Basic monthly


***