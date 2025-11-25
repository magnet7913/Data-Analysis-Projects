# Case Study #1: Danny's Diner

## Case Study Questions

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

---

### 1. What is the total amount each customer spent at the restaurant?

```sql
SELECT
  s.customer_id,
  SUM(m.price) AS spent
FROM
  sales s
  JOIN menu m ON s.product_id = m.product_id
GROUP BY
  1
;
```

#### Result set:

| customer_id | spent |
|-------------|-------|
| A           | 76    |
| B           | 74    |
| C           | 36    |

---

### 2. How many days has each customer visited the restaurant?

```sql
SELECT
  s.customer_id,
  COUNT(DISTINCT (order_date)) count_date
FROM
  sales s
GROUP BY
  1
;
```

#### Result set

| customer_id | count_date |
|-------------|------------|
| A           | 4          |
| B           | 6          |
| C           | 2          |

---

### 3. What was the first item from the menu purchased by each customer?

```sql
SELECT
  cid,
  pn
FROM
  (
    SELECT
      s.customer_id cid,
      m.product_name pn,
      ROW_NUMBER() OVER (
        PARTITION BY
          s.customer_id
        ORDER BY
          s.order_date
      ) AS rn
    FROM
      sales s
      JOIN menu m ON s.product_id = m.product_id
  ) t
WHERE
  rn = 1
;
```

#### Result set

| cid | pn    |
|-----|-------|
| A   | sushi |
| B   | curry |
| C   | ramen |

---

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```sql
SELECT
  m.product_name,
  COUNT(s.product_id) AS quantity
FROM
  sales s
  JOIN menu m ON s.product_id = m.product_id
GROUP BY
  1
ORDER BY
  2 DESC
;
```

#### Result set

| product_name | quantity |
|--------------|----------|
| ramen        | 8        |
| curry        | 4        |
| sushi        | 3        |

---

### 5. Which item was the most popular for each customer?

```sql
SELECT
  cid,
  pn
FROM
  (
    SELECT
      s.customer_id cid,
      m.product_name pn,
      COUNT(s.product_id),
      RANK() OVER (
        PARTITION BY
          s.customer_id
        ORDER BY
          COUNT(s.product_id) DESC
      ) AS rn
    FROM
      sales s
      JOIN menu m ON s.product_id = m.product_id
    GROUP BY
      1,
      2
  ) t
WHERE
  rn = 1
;
```

#### Result set

| cid | pn    |
|-----|-------|
| A   | ramen |
| B   | curry |
| B   | sushi |
| B   | ramen |
| C   | ramen |

---

### 6. Which item was purchased first by the customer after they became a member?

```sql
SELECT
  t.cid,
  m.product_name
FROM
  (
    SELECT
      s.customer_id cid,
      s.product_id pid,
      ROW_NUMBER() OVER (
        PARTITION BY
          s.customer_id
        ORDER BY
          order_date
      ) AS rn
    FROM
      sales s
      JOIN members m ON s.customer_id = m.customer_id
    WHERE
      s.order_date >= m.join_date
  ) t
  JOIN menu m ON t.pid = m.product_id
WHERE
  rn = 1
;
```

#### Result set

| cid | product_name |
|-----|--------------|
| B   | sushi        |
| A   | curry        |

---

### 7. Which item was purchased just before the customer became a member?

```sql
SELECT
  t.cid,
  m.product_name
FROM
  (
    SELECT
      s.customer_id cid,
      s.product_id pid,
      ROW_NUMBER() OVER (
        PARTITION BY
          s.customer_id
        ORDER BY
          order_date DESC
      ) AS rn
    FROM
      sales s
      JOIN members m ON s.customer_id = m.customer_id
    WHERE
      s.order_date < m.join_date
  ) t
  JOIN menu m ON t.pid = m.product_id
WHERE
  rn = 1
;
```

#### Result set

| cid | product_name |
|-----|--------------|
| A   | sushi        |
| B   | sushi        |

---

### 8. What is the total items and amount spent for each member before they became a member?

```sql
SELECT
  s.customer_id,
  COUNT(s.product_id) count_pre_mem,
  SUM(me.price) spent_pre_mem
FROM
  sales s
  JOIN members m ON s.customer_id = m.customer_id
  JOIN menu me ON me.product_id = s.product_id
WHERE
  s.order_date < m.join_date
GROUP BY
  1
;
```

#### Result set

| customer_id | count_pre_mem | spent_pre_mem |
|-------------|---------------|---------------|
| B           | 3             | 40            |
| A           | 2             | 25            |

---

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```sql
SELECT
  t.cid,
  SUM(t.earned_point) AS points
FROM
  (
    SELECT
      s.customer_id cid,
      s.product_id pid,
      CASE
        WHEN me.product_name = 'sushi' THEN 20 * me.price
        ELSE 10 * me.price
      END AS earned_point
    FROM
      sales s
      JOIN members m ON s.customer_id = m.customer_id
      JOIN menu me ON s.product_id = me.product_id
    WHERE
      s.order_date >= m.join_date
  ) t
GROUP BY
  1
;
```

#### Result set

| cid | points |
|-----|--------|
| B   | 440    |
| A   | 510    |

---

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

```sql
SELECT
  t.cid,
  SUM(
    CASE
      WHEN t.od <= adddate (t.jd, 7) THEN 20 * me.price
      WHEN me.product_name = 'sushi' THEN 20 * me.price
      ELSE 10 * me.price
    END
  ) AS ep
FROM
  (
    SELECT
      s.customer_id cid,
      s.product_id pid,
      s.order_date od,
      m.join_date jd
    FROM
      sales s
      JOIN members m ON s.customer_id = m.customer_id
    WHERE
      s.order_date >= m.join_date
  ) t
  JOIN menu me ON me.product_id = t.pid
GROUP BY
  1
```

#### Result set

| cid | ep    |
|-----|-------|
| B   | 560   |
| A   | 1020  |

---
