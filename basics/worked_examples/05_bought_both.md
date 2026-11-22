# Worked example B5 · Customers who bought from both categories

**Problem.** Cross-selling wants customers who have bought **both** Books **and** Electronics (in paid orders).

**Run:** `python tools/run_sql.py basics/worked_examples/05_bought_both.sql`

## 1. Plan

"Both" is a condition on a **set** of rows per customer, not on any single row. One order line can only be in one category, so a `WHERE` on a single row can never see both.

In the sample data nobody qualifies yet, so Ana (who bought a keyboard and a mouse) also buys a book:

```sql
INSERT INTO orders VALUES (120, 1, '2026-08-10', 'paid');
INSERT INTO order_items VALUES (120, 7, 1, 5500);
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*
<!-- /result -->

## 2. Tempting attempt

```sql
SELECT DISTINCT o.customer_id
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
JOIN products p    ON p.product_id = i.product_id
JOIN categories c  ON c.category_id = p.category_id
WHERE o.status = 'paid'
  AND c.category_name = 'Books'
  AND c.category_name = 'Electronics';
```

<!-- result -->
| customer_id |
|---|
| *(no rows)* |
<!-- /result -->

No rows, ever: a single row's `category_name` can't equal two values. Changing `AND` to `OR` goes wrong the other way: it returns customers who bought *either*.

## 3. Fix: group per customer, count distinct categories

```sql
SELECT o.customer_id,
       COUNT(DISTINCT c.category_name) AS categories_bought
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
JOIN products p    ON p.product_id = i.product_id
JOIN categories c  ON c.category_id = p.category_id
WHERE o.status = 'paid'
  AND c.category_name IN ('Books', 'Electronics')
GROUP BY o.customer_id
HAVING COUNT(DISTINCT c.category_name) = 2
ORDER BY o.customer_id;
```

<!-- result -->
| customer_id | categories_bought |
|---|---|
| 1 | 2 |
<!-- /result -->

- `WHERE … IN (…)` keeps only the two categories of interest.
- `HAVING COUNT(DISTINCT …) = 2` keeps customers whose remaining rows cover both. `DISTINCT` matters: two Books lines must not count as two categories.

## 4. Test it

```sql
SELECT o.customer_id, c.category_name, COUNT(*) AS lines
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
JOIN products p    ON p.product_id = i.product_id
JOIN categories c  ON c.category_id = p.category_id
WHERE o.status = 'paid' AND c.category_name IN ('Books', 'Electronics')
GROUP BY o.customer_id, c.category_name
ORDER BY o.customer_id, c.category_name;
```

<!-- result -->
| customer_id | category_name | lines |
|---|---|---|
| 1 | Books | 1 |
| 1 | Electronics | 2 |
| 2 | Books | 1 |
| 3 | Books | 1 |
| 6 | Electronics | 1 |
| 7 | Books | 1 |
| 8 | Electronics | 1 |
<!-- /result -->

The detail list shows Ana (customer 1) with lines in both categories, the same customer the `HAVING` query returned. Generalise with `= (number of categories in the list)`, or for "bought *all* categories" compare with `(SELECT COUNT(*) FROM categories)`.

**Practise next:** [PB41](../../practice/starter/PB41.sql), [PI44](../../practice/starter/PI44.sql).
