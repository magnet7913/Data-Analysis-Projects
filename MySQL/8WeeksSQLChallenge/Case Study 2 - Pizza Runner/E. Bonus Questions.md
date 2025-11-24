# Case Study #2: Pizza runner - Bonus Question

- If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

The pizza_names and pizza_recipes tables must be updated

```sql
insert into pizza_names (pizza_id, pizza_name)
values (3,'Supreme')
;
```
| pizza_id | pizza_name  |
|---------:|-------------|
| 1        | Meatlovers  |
| 2        | Vegetarian  |
| 3        | Supreme     |

```sql
insert into pizza_recipes (pizza_id, toppings)
values(3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12')
;
```
| pizza_id | orders |
|---------:|--------|
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 |
| 2        | 4, 6, 7, 9, 11, 12 |
| 3        | 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 |

This modification should not cause any disruption to the existing data structure, we simply add a new entry to the existing tables.