# 08 · INSERT, UPDATE, DELETE

> **You will learn** to add rows with `INSERT` (including `INSERT … SELECT`), change them with `UPDATE`, remove them with `DELETE`, how constraints protect the data, and how to make every change safe with a transaction and a check of the affected rows.
> **Time:** about 50 minutes · **Before this:** [07 · LEFT JOIN and missing data](07_left_join.md)

So far you have only read data. These three statements change it, and **there is no undo button** outside a transaction. The habits in this lesson (preview with `SELECT`, wrap in a transaction, check the row count) are what separate a safe engineer from an incident report.

**Run the whole lesson:** `python tools/run_sql.py basics/lessons/08_dml.sql`. The runner uses a disposable in-memory database, so experiment freely.

## 1. INSERT

Always list the columns. The statement then keeps working when someone adds a column with a default, and readers can see which value goes where.

```sql
INSERT INTO products (product_id, sku, category_id, product_name, unit_price_cents, active)
VALUES (20, 'P20', 2, 'Stapler', 1800, 1);

SELECT product_id, sku, product_name, unit_price_cents
FROM products
WHERE product_id = 20;
```

<!-- result -->
*Rows changed: 1*

| product_id | sku | product_name | unit_price_cents |
|---|---|---|---|
| 20 | P20 | Stapler | 1800 |
<!-- /result -->

One statement can insert several rows: `VALUES (…), (…), (…)`. A column you leave out gets its `DEFAULT` (here, `active` defaults to 1), or `NULL` if there is none.

`INSERT … SELECT` copies the result of a query into a table, which is handy for archives and snapshots:

```sql
CREATE TABLE cancelled_orders (order_id INTEGER PRIMARY KEY, customer_id INTEGER, ordered_at TEXT);

INSERT INTO cancelled_orders (order_id, customer_id, ordered_at)
SELECT order_id, customer_id, ordered_at
FROM orders
WHERE status = 'cancelled';

SELECT * FROM cancelled_orders;
```

<!-- result -->
*Rows changed: 1*

| order_id | customer_id | ordered_at |
|---|---|---|
| 106 | 5 | 2026-04-15 |
<!-- /result -->

## 2. Constraints say no

The schema's rules are checked on every write. A failing constraint rejects the **whole statement**:

```sql error
INSERT INTO products (product_id, sku, category_id, product_name, unit_price_cents)
VALUES (21, 'P20', 2, 'Duplicate SKU', 500);
```

<!-- result -->
**Error:** `UNIQUE constraint failed: products.sku`
<!-- /result -->

```sql error
INSERT INTO products (product_id, sku, category_id, product_name, unit_price_cents)
VALUES (22, 'P22', 2, 'Negative price', -1);
```

<!-- result -->
**Error:** `CHECK constraint failed: unit_price_cents >= 0`
<!-- /result -->

```sql error
INSERT INTO orders (order_id, customer_id, ordered_at, status)
VALUES (300, 999, '2026-09-01', 'paid');
```

<!-- result -->
**Error:** `FOREIGN KEY constraint failed`
<!-- /result -->

`UNIQUE`, `CHECK`, `NOT NULL` and `FOREIGN KEY` turn bugs into immediate, loud errors instead of quiet bad data. (SQLite checks foreign keys only when `PRAGMA foreign_keys = ON`. The course runner always turns it on.)

## 3. UPDATE

`UPDATE` changes the columns you `SET`, in every row that matches `WHERE`. **Preview first:** run a `SELECT` with the same `WHERE` and look at what will change.

```sql
SELECT product_id, sku, unit_price_cents
FROM products
WHERE category_id = 2 AND active = 1;

UPDATE products
SET unit_price_cents = unit_price_cents * 110 / 100
WHERE category_id = 2 AND active = 1;

SELECT product_id, sku, unit_price_cents
FROM products
WHERE category_id = 2 AND active = 1;
```

<!-- result -->
| product_id | sku | unit_price_cents |
|---|---|---|
| 1 | P01 | 1200 |
| 2 | P02 | 250 |
| 6 | P06 | 450 |
| 20 | P20 | 1800 |

*Rows changed: 4*

| product_id | sku | unit_price_cents |
|---|---|---|
| 1 | P01 | 1320 |
| 2 | P02 | 275 |
| 6 | P06 | 495 |
| 20 | P20 | 1980 |
<!-- /result -->

- The right-hand side can use the row's current values (`unit_price_cents * 110 / 100`).
- Several columns: `SET a = 1, b = 'x'`.
- **An `UPDATE` without `WHERE` changes every row.** It's a valid statement, which is exactly why it's dangerous.

## 4. DELETE

`DELETE FROM t WHERE …` removes matching rows. Foreign keys protect dependants: you can't delete an order that still has lines.

```sql error
DELETE FROM orders WHERE order_id = 106;
```

<!-- result -->
**Error:** `FOREIGN KEY constraint failed`
<!-- /result -->

Delete the children first, then the parent, and check how many rows each step removed:

```sql
DELETE FROM order_items WHERE order_id = 106;
DELETE FROM orders WHERE order_id = 106;
SELECT COUNT(*) AS orders_left FROM orders;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*

| orders_left |
|---|
| 10 |
<!-- /result -->

Real systems often avoid deleting business records at all, and set a status or a `deleted_at` column instead ("soft delete"), so history and audits stay intact.

## 5. Transactions make changes safe

A **transaction** groups statements so they succeed or fail together. `BEGIN` starts one, `COMMIT` keeps the changes, and `ROLLBACK` throws them all away.

```sql
BEGIN;
UPDATE orders SET status = 'cancelled' WHERE status = 'pending';
SELECT status, COUNT(*) AS orders FROM orders GROUP BY status ORDER BY status;
ROLLBACK;

SELECT status, COUNT(*) AS orders FROM orders GROUP BY status ORDER BY status;
```

<!-- result -->
*Rows changed: 2*

| status | orders |
|---|---|
| cancelled | 2 |
| paid | 8 |

| status | orders |
|---|---|
| paid | 8 |
| pending | 2 |
<!-- /result -->

The safe-change recipe:

1. `BEGIN;`
2. `SELECT` the rows your `WHERE` matches. Is the count what you expect?
3. Run the `UPDATE`/`DELETE` and check *Rows changed*.
4. `SELECT` again to confirm the new state.
5. `COMMIT;` if everything matches, `ROLLBACK;` if anything surprises you.

SQLite 3.35+ and PostgreSQL also support `RETURNING`, which makes a write report the rows it touched: `UPDATE … RETURNING product_id, unit_price_cents;`.

## Common mistakes

| Mistake | What happens | Fix |
|---|---|---|
| `UPDATE`/`DELETE` without `WHERE` | Every row changes | Preview with `SELECT`; work inside a transaction |
| `INSERT INTO t VALUES (…)` without a column list | Breaks or misplaces values when columns change | Always list the columns |
| Deleting a parent before its children | Foreign-key error (or orphans if checks are off) | Children first, or soft-delete |
| Not checking the affected row count | A typo in `WHERE` goes unnoticed | Compare *Rows changed* with your preview |
| Forgetting `COMMIT` | Changes vanish when the connection closes | Finish every transaction explicitly |

## Your turn

These are **script** exercises: write the statements, and the checker inspects the database afterwards. It sometimes also tries follow-up statements that your constraints must accept or reject.

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PB49` | **Add a product.** Insert product 20: sku 'P20', category 2, name 'Stapler', price 1800 cents, active. List the columns explicitly. The checker reads product 20 and then tries to insert another product with sku 'P20'. | script |
| `PB50` | **Stationery price rise.** Raise the price of every active Stationery product (category 2) by 10%, rounding down to whole cents with integer arithmetic. Other products must not change. | script |
| `PB51` | **Cancel stale pending orders.** Set status to 'cancelled' for pending orders placed before 2026-04-01. Leave every other order unchanged. | script |
| `PB52` | **Remove an order completely.** Delete order 106 together with its order lines, in an order the foreign keys accept. Nothing else may be deleted. | script |
| `PB53` | **Archive cancelled orders.** Create table archived_orders(order_id INTEGER PRIMARY KEY, customer_id INTEGER NOT NULL, ordered_at TEXT NOT NULL) and fill it with every cancelled order using INSERT … SELECT. | script |

```bash
python tools/practice.py show PB49
python tools/practice.py check PB49
python tools/practice.py hint PB49 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** What does `UPDATE products SET active = 0;` change?

   - **a)** Nothing without WHERE
   - **b)** Every product
   - **c)** Only the first product

**2.** Why list the columns in an INSERT?

   - **a)** It's required by SQL
   - **b)** It keeps working when columns are added and shows which value goes where
   - **c)** It's faster

**3.** You run `BEGIN; DELETE …; ROLLBACK;`. What happened to the rows?

   - **a)** They are still there
   - **b)** They are deleted
   - **c)** They are deleted until restart

**4.** Deleting an order that still has order_items fails because of…

   - **a)** a CHECK constraint
   - **b)** a FOREIGN KEY constraint
   - **c)** a UNIQUE constraint

```bash
python tools/quiz.py basics/08 1 b      # question 1, answer b
python tools/quiz.py basics/08           # list the questions
```
<!-- /quiz -->

## Summary

- `INSERT` with an explicit column list; `INSERT … SELECT` copies query results.
- `UPDATE … SET … WHERE` and `DELETE … WHERE` change only matching rows. Without `WHERE`, they change all of them.
- Constraints reject bad writes; foreign keys protect dependants.
- Preview, wrap in `BEGIN … COMMIT/ROLLBACK`, and check the affected row count.

**Next:** [09 · Basics review: order report](09_review.md)
