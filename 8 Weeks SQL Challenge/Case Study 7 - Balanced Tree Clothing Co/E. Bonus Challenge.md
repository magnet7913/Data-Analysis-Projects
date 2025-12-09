## Case Study #6: Balanced Tree Clothing Co. - Bonus Challenge

Use a single SQL query to transform the product_hierarchy and product_prices datasets to the product_details table.

Hint: you may want to consider using a recursive CTE to solve this problem!

```sql
-- Recursive CTE would be overkilled for this question. Just join the table with itself a few times would be enough :)
SELECT
  product_id,
  price,
  CONCAT(
    ph2.level_text,
    " ",
    ph.level_text,
    " - ",
    ph3.level_text
  ) product_name,
  ph3.id category_id,
  ph2.id segment_id,
  ph.id style_id,
  ph3.level_text category_name,
  ph2.level_text segment_name,
  ph.level_text style_name
FROM
  product_prices pp
  LEFT JOIN product_hierarchy ph ON pp.id = ph.id
  LEFT JOIN product_hierarchy ph2 ON ph.parent_id = ph2.id
  LEFT JOIN product_hierarchy ph3 ON ph2.parent_id = ph3.id
;
```

#### Result set:

| product_id | price | product_name                  | category_id | segment_id | style_id | category_name | segment_name | style_name          |
|------------|-------|-------------------------------|-------------|------------|----------|---------------|--------------|---------------------|
| c4a632     | 13    | Jeans Navy Oversized - Womens | 1           | 3          | 7        | Womens        | Jeans        | Navy Oversized      |
| e83aa3     | 32    | Jeans Black Straight - Womens | 1           | 3          | 8        | Womens        | Jeans        | Black Straight      |
| e31d39     | 10    | Jeans Cream Relaxed - Womens  | 1           | 3          | 9        | Womens        | Jeans        | Cream Relaxed       |
| d5e9a6     | 23    | Jacket Khaki Suit - Womens    | 1           | 4          | 10       | Womens        | Jacket       | Khaki Suit          |
| 72f5d4     | 19    | Jacket Indigo Rain - Womens   | 1           | 4          | 11       | Womens        | Jacket       | Indigo Rain         |
| 9ec847     | 54    | Jacket Grey Fashion - Womens  | 1           | 4          | 12       | Womens        | Jacket       | Grey Fashion        |
| 5d267b     | 40    | Shirt White Tee - Mens        | 2           | 5          | 13       | Mens          | Shirt        | White Tee           |
| c8d436     | 10    | Shirt Teal Button Up - Mens   | 2           | 5          | 14       | Mens          | Shirt        | Teal Button Up      |
| 2a2353     | 57    | Shirt Blue Polo - Mens        | 2           | 5          | 15       | Mens          | Shirt        | Blue Polo           |
| f084eb     | 36    | Socks Navy Solid - Mens       | 2           | 6          | 16       | Mens          | Socks        | Navy Solid          |
| b9a74d     | 17    | Socks White Striped - Mens    | 2           | 6          | 17       | Mens          | Socks        | White Striped       |
| 2feb6b     | 29    | Socks Pink Fluro Polkadot - Mens | 2        | 6          | 18       | Mens          | Socks        | Pink Fluro Polkadot |

***