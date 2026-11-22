# 07 · LEFT JOIN and missing data

> **You will learn** to keep rows that have no match with `LEFT JOIN`, to find "missing" things (customers without orders, products never sold), why a `WHERE` on the right table can undo a left join, and how to report zeros instead of gaps.
> **Time:** about 45 minutes · **Before this:** [06 · INNER JOIN relationships](06_joins.md)

An inner join answers "show me orders *with* their customers". Many real questions are about what is **absent**: customers who never ordered, employees with no manager, categories with no sales. An inner join silently drops exactly those rows. `LEFT JOIN` keeps them.

**Run the whole lesson:** `python tools/run_sql.py basics/lessons/07_left_join.sql`

## 1. Keep every left row

`A LEFT JOIN B` returns every row of `A`. When a row of `A` has a match in `B`, you get the combined row; when it has none, `B`'s columns are `NULL`.

Lesson 01 showed that the top-level employees have no manager. A self-join with `LEFT JOIN` keeps them in the list:

```sql
SELECT e.full_name AS employee, m.full_name AS manager
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id
ORDER BY e.employee_id;
```

<!-- result -->
| employee | manager |
|---|---|
| Ada | *NULL* |
| Ben | Ada |
| Cleo | *NULL* |
| Dina | Cleo |
| Ema | *NULL* |
| Fadi | Ada |
| Gina | Ema |
| Hugo | Cleo |
<!-- /result -->

With a plain `JOIN`, Ada, Cleo and Ema would vanish. **Which side is "left" matters:** it is the table written before `LEFT JOIN`, the one whose rows you must keep.

## 2. Finding what is missing (anti-join)

After a `LEFT JOIN`, an unmatched row has `NULL` in the right table's **key**. Filtering on that finds the left rows with no match at all. This is an *anti-join*. In the sample data every product has been ordered, so add one that hasn't (inside a transaction, so the dataset stays clean):

```sql
BEGIN;
INSERT INTO products VALUES (20, 'P20', 4, 'Plant Pot', 1900, 1);

SELECT p.sku, p.product_name
FROM products p
LEFT JOIN order_items i ON i.product_id = p.product_id
WHERE i.product_id IS NULL;

ROLLBACK;
```

<!-- result -->
*Rows changed: 1*

| sku | product_name |
|---|---|
| P20 | Plant Pot |
<!-- /result -->

Test the right table's **join key** (or primary key) for `NULL`. Other columns might be legitimately `NULL` in matched rows.

## 3. Counting with zeros

To count orders per customer *including customers with none*, start from customers, left-join orders, and count a column from the right side:

```sql
BEGIN;
INSERT INTO customers VALUES (20, 'Ioana Nou', 'ioana@example.test', 'Arad', '2026-08-01');

SELECT c.customer_id, c.full_name,
       COUNT(o.order_id) AS orders,
       COUNT(*)          AS rows_in_group
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY c.customer_id;

ROLLBACK;
```

<!-- result -->
*Rows changed: 1*

| customer_id | full_name | orders | rows_in_group |
|---|---|---|---|
| 1 | Ana Ionescu | 2 | 2 |
| 2 | Bogdan Pop | 2 | 2 |
| 3 | Carmen Radu | 2 | 2 |
| 4 | Darius Ene | 1 | 1 |
| 5 | Elena Stan | 1 | 1 |
| 6 | Florin Matei | 1 | 1 |
| 7 | Gabriela Dinu | 1 | 1 |
| 8 | Horia Vlad | 1 | 1 |
| 20 | Ioana Nou | 0 | 1 |
<!-- /result -->

Ioana has `orders = 0` but `rows_in_group = 1`: the unmatched row still exists, it just has `NULL` in `o.order_id`. **`COUNT(*)` counts that row; `COUNT(o.order_id)` doesn't.** For sums, wrap in `COALESCE(SUM(…), 0)`.

## 4. ON vs WHERE in a left join

This is the most common left-join bug. Suppose you want every customer with their number of **paid** orders:

```sql
SELECT c.full_name, COUNT(o.order_id) AS paid_orders
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'paid'
GROUP BY c.customer_id, c.full_name
ORDER BY c.customer_id;
```

<!-- result -->
| full_name | paid_orders |
|---|---|
| Ana Ionescu | 2 |
| Bogdan Pop | 1 |
| Carmen Radu | 1 |
| Darius Ene | 1 |
| Florin Matei | 1 |
| Gabriela Dinu | 1 |
| Horia Vlad | 1 |
<!-- /result -->

Elena (customer 5, whose only order was cancelled) is missing. For her, the joined rows have `o.status = 'cancelled'`, and `WHERE` removes them. A customer with no orders at all would have `NULL` and be removed too. **A `WHERE` condition on the right table turns a left join into an inner join.** Put the condition in `ON` so it limits what counts as a *match*:

```sql
SELECT c.full_name, COUNT(o.order_id) AS paid_orders
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'paid'
GROUP BY c.customer_id, c.full_name
ORDER BY c.customer_id;
```

<!-- result -->
| full_name | paid_orders |
|---|---|
| Ana Ionescu | 2 |
| Bogdan Pop | 1 |
| Carmen Radu | 1 |
| Darius Ene | 1 |
| Elena Stan | 0 |
| Florin Matei | 1 |
| Gabriela Dinu | 1 |
| Horia Vlad | 1 |
<!-- /result -->

| Condition on… | Put it in… | Effect |
|---|---|---|
| the left (kept) table | `WHERE` | which left rows appear at all |
| the right (optional) table | `ON` | which right rows count as a match |
| "right side missing" | `WHERE right.key IS NULL` | anti-join |

## 5. Other outer joins

- `RIGHT JOIN` is a `LEFT JOIN` with the tables swapped. Most people always write `LEFT JOIN` and order the tables accordingly.
- `FULL JOIN` keeps unmatched rows from **both** sides (SQLite 3.39+, PostgreSQL). It's useful in reconciliation reports.
- `CROSS JOIN` pairs every row with every row. It's occasionally useful (every product × every month), and dangerous by accident.

## Common mistakes

| Mistake | What happens | Fix |
|---|---|---|
| Right-table filter in `WHERE` | Unmatched rows disappear | Move it into `ON` |
| `COUNT(*)` to count matches | Unmatched rows count as 1 | `COUNT(right.key)` |
| `SUM` with no matches | `NULL` instead of 0 | `COALESCE(SUM(x), 0)` |
| Anti-join testing a nullable column | Matched rows with a NULL value look missing | Test the right table's key |
| Tables in the wrong order | You keep the wrong side | The table you must keep goes first |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PB18` | **Employees and managers.** Return employee (the employee's name) and manager (the manager's name, NULL when there is none) for every employee, sorted by employee_id. | query |
| `PB19` | **Never ordered.** Return sku, product_name for products that never appear in any order line, sorted by sku. (The course dataset has none; the edge fixture has one.) | query |
| `PB46` | **Order count including zero.** Return customer_id, full_name, order_count (orders of any status, 0 for none) for every customer, sorted by customer_id. | query |
| `PB47` | **Empty teams.** Return team_name for teams that have no employees, sorted by team_name. (The course data has none; the edge fixture adds one.) | query |
| `PB48` | **Paid orders including zero.** Return customer_id, paid_orders (number of paid orders, 0 for none) for every customer, sorted by customer_id. | query |

```bash
python tools/practice.py show PB18
python tools/practice.py check PB18
python tools/practice.py hint PB18 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** In `customers c LEFT JOIN orders o`, which rows are always kept?

   - **a)** All customers
   - **b)** All orders
   - **c)** Only matching pairs

**2.** After a LEFT JOIN, which COUNT gives 0 for a customer with no orders?

   - **a)** COUNT(*)
   - **b)** COUNT(o.order_id)
   - **c)** COUNT(c.customer_id)

**3.** Where should `o.status = 'paid'` go to keep customers without paid orders?

   - **a)** WHERE
   - **b)** HAVING
   - **c)** The ON clause

**4.** How do you find products that were never ordered?

   - **a)** LEFT JOIN order_items … WHERE i.product_id IS NULL
   - **b)** JOIN order_items … WHERE i.quantity = 0
   - **c)** WHERE product_id NOT NULL

```bash
python tools/quiz.py basics/07 1 b      # question 1, answer b
python tools/quiz.py basics/07           # list the questions
```
<!-- /quiz -->

## Summary

- `LEFT JOIN` keeps every row of the left table; missing matches are `NULL`.
- `WHERE right.key IS NULL` finds rows with no match (anti-join).
- Count matches with `COUNT(right.key)`; use `COALESCE` for zero sums.
- Conditions on the right table go in `ON`, not `WHERE`.

**Next:** [08 · INSERT, UPDATE, DELETE](08_dml.md)
