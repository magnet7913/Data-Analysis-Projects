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
select s.customer_id, sum(m.price) as spent
from sales s
join menu m on
s.product_id = m.product_id
group by 1
;
```

#### Result set:

| customer_id | total_sales |
| ----------- | ----------- |
| A           | $76         |
| B           | $74         |
| C           | $36         |

---

### 2. How many days has each customer visited the restaurant?

```sql
select s.customer_id, count(distinct(order_date)) count_date
from sales s
group by 1
;
```

#### Result set

---

### 3

```sql
select cid, pn from (
select s.customer_id cid, m.product_name pn, row_number() over (partition by s.customer_id order by s.order_date) as rn
from sales s
join menu m on
s.product_id = m.product_id) t
where rn = 1
;
```

#### Result set

---

### 4

```sql
select m.product_name, count(s.product_id)
from sales s
join menu m
on
s.product_id = m.product_id
group by 1
order by 2 desc
;
```

#### Result set

---

### 5

```sql
select cid, pn
from (select 	s.customer_id cid,m.product_name pn,
		count(s.product_id),
		rank() over (partition by s.customer_id order by count(s.product_id) desc) as rn
from sales s
join menu m
on
s.product_id = m.product_id
group by 1, 2) t
where rn = 1
;
```

#### Result set

---

### 6

```sql
select t.cid, m.product_name
from (select s.customer_id cid, s.product_id pid, row_number() over (partition by s.customer_id order by order_date ) as rn
from sales s
join members m
on s.customer_id = m.customer_id
where s.order_date >= m.join_date) t
join menu m
on t.pid = m.product_id
where rn = 1
;
```

#### Result set

---

### 7

```sql
select t.cid, m.product_name
from (select s.customer_id cid, s.product_id pid, row_number() over (partition by s.customer_id order by order_date desc ) as rn
from sales s
join members m
on s.customer_id = m.customer_id
where s.order_date < m.join_date) t
join menu m
on t.pid = m.product_id
where rn = 1
;
```

#### Result set

---

### 8

```sql
select s.customer_id,count(s.product_id) count_pre_mem, sum(me.price) spent_pre_mem
from sales s
join members m
on s.customer_id = m.customer_id
join menu me
on me.product_id = s.product_id
where s.order_date < m.join_date
group by 1
;
```

#### Result set

---

### 9

```sql
select t.cid, sum(t.earned_point)
from (select s.customer_id cid, s.product_id pid,
	case when me.product_name = 'suchi' then 20*me.price
    else 10*me.price
    end as earned_point
from sales s
join members m
on s.customer_id = m.customer_id
join menu me
on s.product_id = me.product_id
where s.order_date >= m.join_date) t
group by 1
;
```

#### Result set

---

### 10

```sql
select t.cid, sum(
    case when t.od <= adddate(t.jd,7) then 20*me.price
    when me.product_name = 'sushi' then 20*me.price
    else 10*me.price
    end) as ep
from (select s.customer_id cid, s.product_id pid, s.order_date od, m.join_date jd
from sales s
join members m
on s.customer_id = m.customer_id
where s.order_date >= m.join_date) t
join menu me
on me.product_id = t.pid
group by 1
```

#### Result set

---
