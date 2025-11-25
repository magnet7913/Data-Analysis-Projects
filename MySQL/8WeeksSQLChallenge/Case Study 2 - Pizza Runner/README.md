# Case Study #2: Pizza Runner
<p align="center">
<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" alt="Image" width="450" height="450">

View the case study [here](https://8weeksqlchallenge.com/case-study-2/)

## Table Of Contents
  - [Introduction](#introduction)
  - [Dataset](#dataset)
  - [Entity Relationship Diagram](#entity-relationship-diagram)
  - [Case Study Solutions](#case-study-solutions)
  
## Introduction
Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

## Dataset
Key datasets for this case study
- **runners** : The table shows the registration_date for each new runner

<div align="center">

| runner_id | registration_date |
|-----------|-------------------|
| 1         | 2021-01-01        |
| 2         | 2021-01-03        |
| 3         | 2021-01-08        |
| 4         | 2021-01-15        |

</div>

- **customer_orders** : Customer pizza orders are captured in the customer_orders table with 1 row for each individual pizza that is part of the order. The pizza_id relates to the type of pizza which was ordered whilst the exclusions are the ingredient_id values which should be removed from the pizza and the extras are the ingredient_id values which need to be added to the pizza.

<div align="center">

| order_id | customer_id | pizza_id | exclusions | extras   | order_time          |
|----------|-------------|----------|------------|----------|---------------------|
| 1        | 101         | 1        |            |          | 2021-01-01 18:05:02 |
| 2        | 101         | 1        |            |          | 2021-01-01 19:00:52 |
| 3        | 102         | 1        |            |          | 2021-01-02 23:51:23 |
| 3        | 102         | 2        |            | NaN      | 2021-01-02 23:51:23 |
| 4        | 103         | 1        | 4          |          | 2021-01-04 13:23:46 |
| 4        | 103         | 1        | 4          |          | 2021-01-04 13:23:46 |
| 4        | 103         | 2        | 4          |          | 2021-01-04 13:23:46 |
| 5        | 104         | 1        | null       | 1        | 2021-01-08 21:00:29 |
| 6        | 101         | 2        | null       | null     | 2021-01-08 21:03:13 |
| 7        | 105         | 2        | null       | 1        | 2021-01-08 21:20:29 |
| 8        | 102         | 1        | null       | null     | 2021-01-09 23:54:33 |
| 9        | 103         | 1        | 4          | 1, 5     | 2021-01-10 11:22:59 |
| 10       | 104         | 1        | null       | null     | 2021-01-11 18:34:49 |
| 10       | 104         | 1        | 2, 6       | 1, 4     | 2021-01-11 18:34:49 |

</div>

- **runner_orders** : After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and can be cancelled by the restaurant or the customer. The pickup_time is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. The distance and duration fields are related to how far and long the runner had to travel to deliver the order to the respective customer.

<div align="center">

| order_id | runner_id | pickup_time         | distance | duration    | cancellation            |
|----------|-----------|---------------------|----------|-------------|-------------------------|
| 1        | 1         | 2021-01-01 18:15:34 | 20km     | 32 minutes  |                         |
| 2        | 1         | 2021-01-01 19:10:54 | 20km     | 27 minutes  |                         |
| 3        | 1         | 2021-01-03 00:12:37 | 13.4km   | 20 mins     | NaN                     |
| 4        | 2         | 2021-01-04 13:53:03 | 23.4     | 40          | NaN                     |
| 5        | 3         | 2021-01-08 21:10:57 | 10       | 15          | NaN                     |
| 6        | 3         | null                | null     | null        | Restaurant Cancellation |
| 7        | 2         | 2020-01-08 21:30:45 | 25km     | 25mins      | null                    |
| 8        | 2         | 2020-01-10 00:15:02 | 23.4 km  | 15 minute   | null                    |
| 9        | 2         | null                | null     | null        | Customer Cancellation   |
| 10       | 1         | 2020-01-11 18:50:20 | 10km     | 10minutes   | null                    |

</div>

- **pizza_names** : Pizza Runner only has 2 pizzas available the Meat Lovers or Vegetarian!

<div align="center">

| pizza_id | pizza_name  |
|----------|-------------|
| 1        | Meat Lovers |
| 2        | Vegetarian  |

</div>

- **pizza_recipes** : Each pizza_id has a standard set of toppings which are used as part of the pizza recipe.

<div align="center">

| pizza_id | toppings                  |
|----------|---------------------------|
| 1        | 1, 2, 3, 4, 5, 6, 8, 10    |
| 2        | 4, 6, 7, 9, 11, 12         |

</div>

- **pizza_toppings** : The table contains all of the topping_name values with their corresponding topping_id value

<div align="center">

| topping_id | topping_name  |
|------------|---------------|
| 1          | Bacon         |
| 2          | BBQ Sauce     |
| 3          | Beef          |
| 4          | Cheese        |
| 5          | Chicken       |
| 6          | Mushrooms     |
| 7          | Onions        |
| 8          | Pepperoni     |
| 9          | Peppers       |
| 10         | Salami        |
| 11         | Tomatoes      |
| 12         | Tomato Sauce  |

</div>

## Entity Relationship Diagram
![alt text](https://github.com/magnet7913/Data-Analysis-Projects/blob/main/MySQL/8WeeksSQLChallenge/Case%20Study%202%20-%20Pizza%20Runner/images/Case2Rela.png)

## Data Clean
There are some known data issues with few tables. Data cleaning was performed and saved in temporary tables before attempting the case study.

**customer_orders table**
- The exclusions and extras columns in customer_orders table will need to be cleaned up before using them in the queries
- In the exclusions and extras columns, there are blank spaces and null values.

**runner_orders table**
- The pickup_time, distance, duration and cancellation columns in runner_orders table will need to be cleaned up before using them in the queries
- In the pickup_time column, there are null values.
- In the distance column, there are null values. It contains unit - km. The 'km' must also be stripped
- In the duration column, there are null values. The 'minutes', 'mins' 'minute' must be stripped
- In the cancellation column, there are blank spaces and null values.

## Case Study Solutions
- [Data cleaning](https://github.com/magnet7913/Data-Analysis-Projects/blob/main/MySQL/8WeeksSQLChallenge/Case%20Study%202%20-%20Pizza%20Runner/0.%20Data%20Cleaning.md)
- [A. Pizza Metrics](https://github.com/magnet7913/Data-Analysis-Projects/blob/main/MySQL/8WeeksSQLChallenge/Case%20Study%202%20-%20Pizza%20Runner/A.%20Pizza%20metrics.md)
- [B. Runner and Customer Experience](https://github.com/magnet7913/Data-Analysis-Projects/blob/main/MySQL/8WeeksSQLChallenge/Case%20Study%202%20-%20Pizza%20Runner/B.%20Runner%20and%20Customer%20Experience.md)
- [C. Ingredient Optimisation](https://github.com/magnet7913/Data-Analysis-Projects/blob/main/MySQL/8WeeksSQLChallenge/Case%20Study%202%20-%20Pizza%20Runner/C.%20Ingredient%20Optimisation.md)
- [D. Pricing and Ratings](https://github.com/magnet7913/Data-Analysis-Projects/blob/main/MySQL/8WeeksSQLChallenge/Case%20Study%202%20-%20Pizza%20Runner/D.%20Pricing%20and%20Ratings.md)
- [E. Bonus Questions](https://github.com/magnet7913/Data-Analysis-Projects/blob/main/MySQL/8WeeksSQLChallenge/Case%20Study%202%20-%20Pizza%20Runner/E.%20Bonus%20Questions.md)