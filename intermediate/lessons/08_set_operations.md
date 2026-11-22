# 08 · UNION, INTERSECT, EXCEPT

> **You will learn** to stack and compare whole result sets with `UNION`, `UNION ALL`, `INTERSECT` and `EXCEPT`, the rules for compatible columns, why `UNION ALL` is usually what you want, and how to use `EXCEPT` to test that two queries agree.
> **Time:** about 40 minutes · **Before this:** [02 · EXISTS and correlated subqueries](02_exists.md)

Joins put tables **side by side**. Set operations put results **on top of each other**, or compare them as sets: "everyone who either ordered or paid", "customers in both lists", "rows in report A but not in report B".

**Run the whole lesson:** `python tools/run_sql.py intermediate/lessons/08_set_operations.sql`

## 1. UNION ALL and UNION

`UNION ALL` appends the rows of the second query to the first. `UNION` does the same and then **removes duplicate rows**.

```sql
SELECT customer_id FROM orders WHERE status = 'pending'
UNION ALL
SELECT customer_id FROM orders WHERE status = 'paid' AND customer_id <= 3
ORDER BY customer_id;
```

<!-- result -->
| customer_id |
|---|
| 1 |
| 1 |
| 2 |
| 2 |
| 3 |
| 3 |
<!-- /result -->

```sql
SELECT customer_id FROM orders WHERE status = 'pending'
UNION
SELECT customer_id FROM orders WHERE status = 'paid' AND customer_id <= 3
ORDER BY customer_id;
```

<!-- result -->
| customer_id |
|---|
| 1 |
| 2 |
| 3 |
<!-- /result -->

**Rules for every set operation:**

- Each `SELECT` must return the **same number of columns**, with compatible types, matched **by position** (not by name).
- Column names come from the **first** `SELECT`.
- One `ORDER BY` at the very end sorts the combined result.

Prefer `UNION ALL` unless you really need de-duplication: `UNION` must sort or hash every row to find duplicates, and it can also hide genuine repeated rows that you wanted to count.

## 2. Building a timeline with UNION ALL

A common use is stacking different events into one feed. Add a constant column that says where each row came from:

```sql
SELECT ordered_at AS happened_at, 'order'   AS event, order_id AS ref, NULL AS amount_cents
FROM orders WHERE customer_id = 1
UNION ALL
SELECT paid_at, 'payment', order_id, amount_cents
FROM payments WHERE order_id IN (SELECT order_id FROM orders WHERE customer_id = 1)
ORDER BY happened_at, event;
```

<!-- result -->
| happened_at | event | ref | amount_cents |
|---|---|---|---|
| 2026-01-12 | order | 101 | *NULL* |
| 2026-01-12 | payment | 101 | 3150 |
| 2026-03-02 | order | 103 | *NULL* |
| 2026-03-02 | payment | 103 | 22400 |
<!-- /result -->

## 3. INTERSECT: in both

`INTERSECT` keeps rows that appear in **both** results (duplicates removed). Products ordered in a pending order *and* in a paid order:

```sql
SELECT i.product_id FROM order_items i JOIN orders o ON o.order_id = i.order_id WHERE o.status = 'pending'
INTERSECT
SELECT i.product_id FROM order_items i JOIN orders o ON o.order_id = i.order_id WHERE o.status = 'paid'
ORDER BY product_id;
```

<!-- result -->
| product_id |
|---|
| 2 |
| 7 |
<!-- /result -->

## 4. EXCEPT: in the first, not the second

`EXCEPT` keeps rows of the first result that don't appear in the second. Teams that have employees but no team lead (an employee without a manager):

```sql
SELECT team_id FROM employees
EXCEPT
SELECT team_id FROM employees WHERE manager_id IS NULL
ORDER BY team_id;
```

<!-- result -->
| team_id |
|---|
| *(no rows)* |
<!-- /result -->

Every team has a lead today. Moving Ben to a new team shows a team without one:

```sql
BEGIN;
INSERT INTO teams VALUES (4, 'Research');
UPDATE employees SET team_id = 4 WHERE employee_id = 2;

SELECT team_id FROM employees
EXCEPT
SELECT team_id FROM employees WHERE manager_id IS NULL
ORDER BY team_id;

ROLLBACK;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*

| team_id |
|---|
| 4 |
<!-- /result -->

Unlike `NOT IN`, set operations treat two `NULL`s as equal, so `EXCEPT` has no NULL trap.

## 5. EXCEPT as a test: do two queries agree?

When you rewrite a query, prove the new version returns the same rows. Run `EXCEPT` **both ways**: both results must be empty.

```sql
WITH old_version AS (
  SELECT customer_id FROM orders WHERE status = 'paid' GROUP BY customer_id
), new_version AS (
  SELECT c.customer_id FROM customers c
  WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.status = 'paid')
)
SELECT 'only in old' AS side, customer_id FROM (SELECT * FROM old_version EXCEPT SELECT * FROM new_version)
UNION ALL
SELECT 'only in new', customer_id FROM (SELECT * FROM new_version EXCEPT SELECT * FROM old_version);
```

<!-- result -->
| side | customer_id |
|---|---|
| *(no rows)* |  |
<!-- /result -->

No rows: the two queries agree. Because `EXCEPT` removes duplicates, also compare `COUNT(*)` of both versions if duplicate rows matter.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Different column counts | `SELECTs … do not have the same number of result columns` | Same columns in the same positions |
| Columns in a different order | Values silently land in the wrong column | Match by position, alias the first SELECT |
| `UNION` when duplicates are meaningful | Counts too low | `UNION ALL` |
| `ORDER BY` in each part | Error or ignored | One `ORDER BY` at the end |
| Checking a rewrite with `EXCEPT` one way only | Extra rows in the new version go unnoticed | Run both directions, compare counts |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PI06` | **Pending and paid.** Using INTERSECT, return customer_id for customers who have both a pending order and a paid order, sorted by customer_id. | query |
| `PI16` | **UNION vs UNION ALL.** Combine customer_id from pending orders with customer_id from paid orders. Return one row with union_rows (row count using UNION) and union_all_rows (row count using UNION ALL). | query |
| `PI43` | **Pending or paid by transfer.** Using UNION, return customer_id for customers who have a pending order or who paid at least once by transfer, each once, sorted by customer_id. | query |
| `PI44` | **Products in pending and paid orders.** Using INTERSECT, return product_id for products that appear both in a pending order and in a paid order, sorted by product_id. | query |
| `PI45` | **Ordered but never paid.** Using EXCEPT, return customer_id for customers who placed at least one order but never had a paid order, sorted by customer_id. | query |

```bash
python tools/practice.py show PI06
python tools/practice.py check PI06
python tools/practice.py hint PI06 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** What's the difference between UNION and UNION ALL?

   - **a)** UNION removes duplicate rows; UNION ALL keeps them
   - **b)** UNION ALL removes duplicates
   - **c)** None

**2.** Set operations match columns…

   - **a)** by name
   - **b)** by position
   - **c)** by type

**3.** Which keeps rows of the first query that are not in the second?

   - **a)** INTERSECT
   - **b)** EXCEPT
   - **c)** UNION

**4.** To prove a rewritten query returns the same rows, run EXCEPT…

   - **a)** old EXCEPT new only
   - **b)** in both directions, and compare counts
   - **c)** never; use UNION

```bash
python tools/quiz.py intermediate/08 1 b      # question 1, answer b
python tools/quiz.py intermediate/08           # list the questions
```
<!-- /quiz -->

## Summary

- `UNION ALL` stacks results; `UNION` also removes duplicates.
- `INTERSECT` keeps rows in both; `EXCEPT` rows in the first but not the second.
- Parts must have the same number of compatible columns, matched by position.
- `EXCEPT` in both directions is a quick way to prove two queries agree.

**Next:** [09 · Views, savepoints, and transactions](09_views_savepoints.md)
