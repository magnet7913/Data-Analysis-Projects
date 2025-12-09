## Case Study #7: Balanced Tree Clothing Co. - High Level Sales Analysis

1. What was the total quantity sold for all products?
2. What is the total generated revenue for all products before discounts?
3. What was the total discount amount for all products?

### 1. What was the total quantity sold for all products?
```sql
SELECT
  product_name,
  SUM(qty) qty_sold
FROM
  sales s
  JOIN product_details pd ON s.prod_id = pd.product_id
GROUP BY
  1
ORDER BY
  2 DESC;
```

#### Result set:

| product_name                     | qty_sold |
|----------------------------------|----------|
| Grey Fashion Jacket - Womens     | 3876     |
| Navy Oversized Jeans - Womens    | 3856     |
| Blue Polo Shirt - Mens           | 3819     |
| White Tee Shirt - Mens           | 3800     |
| Navy Solid Socks - Mens          | 3792     |
| Black Straight Jeans - Womens    | 3786     |
| Pink Fluro Polkadot Socks - Mens | 3770     |
| Indigo Rain Jacket - Womens      | 3757     |
| Khaki Suit Jacket - Womens       | 3752     |
| Cream Relaxed Jeans - Womens     | 3707     |
| White Striped Socks - Mens       | 3655     |
| Teal Button Up Shirt - Mens      | 3646     |

***

### 2. What is the total generated revenue for all products before discounts?
```sql
SELECT
  product_name,
  SUM(qty * s.price) revenue_bfr_discount
FROM
  sales s
  JOIN product_details pd ON s.prod_id = pd.product_id
GROUP BY
  1
ORDER BY
  2 DESC;
```

#### Result set:

| product_name                     | revenue_bfr_discount |
|----------------------------------|----------------------|
| Blue Polo Shirt - Mens           | 217683               |
| Grey Fashion Jacket - Womens     | 209304               |
| White Tee Shirt - Mens           | 152000               |
| Navy Solid Socks - Mens          | 136512               |
| Black Straight Jeans - Womens    | 121152               |
| Pink Fluro Polkadot Socks - Mens | 109330               |
| Khaki Suit Jacket - Womens       | 86296                |
| Indigo Rain Jacket - Womens      | 71383                |
| White Striped Socks - Mens       | 62135                |
| Navy Oversized Jeans - Womens    | 50128                |
| Cream Relaxed Jeans - Womens     | 37070                |
| Teal Button Up Shirt - Mens      | 36460                |

***

### 3. What was the total discount amount for all products?
```sql
SELECT
  ROUND(SUM(qty * s.price * (discount / 100)), 2) total_discounted
FROM
  sales s
  JOIN product_details pd ON s.prod_id = pd.product_id;
```

#### Result set:

| total_discounted |
|------------------|
| 156229.14        |

***