# 09 · Views, savepoints, and transactions

> **You will learn** to save a query under a name with `CREATE VIEW`, what a view does and doesn't store, to group writes atomically with transactions, to undo part of a transaction with `SAVEPOINT`, and the basics of what other connections see while you work.
> **Time:** about 50 minutes · **Before this:** [03 · Common table expressions](03_cte.md) and [Basics 08 · INSERT, UPDATE, DELETE](../../basics/lessons/08_dml.md)

A CTE names a step for one statement. A **view** names a query for everyone, permanently. Transactions, which Basics introduced, get two more tools: savepoints for partial undo, and an understanding of what *other* sessions can see.

**Run the whole lesson:** `python tools/run_sql.py intermediate/lessons/09_views_savepoints.sql`

## 1. CREATE VIEW

A view is a stored `SELECT` that you can query like a table:

```sql
CREATE VIEW paid_order_totals AS
SELECT o.order_id, o.customer_id, o.ordered_at,
       SUM(i.quantity * i.unit_price_cents) AS total_cents
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.order_id, o.customer_id, o.ordered_at;

SELECT customer_id, COUNT(*) AS paid_orders, SUM(total_cents) AS revenue_cents
FROM paid_order_totals
GROUP BY customer_id
ORDER BY revenue_cents DESC, customer_id
LIMIT 3;
```

<!-- result -->
| customer_id | paid_orders | revenue_cents |
|---|---|---|
| 1 | 2 | 25550 |
| 4 | 1 | 19600 |
| 8 | 1 | 16150 |
<!-- /result -->

- Views give a **single definition** of a business concept ("paid order total") that every report reuses.
- They can hide complexity and limit which columns other users see.
- `DROP VIEW name;` removes it; the underlying data is untouched.

## 2. A view stores the query, not the rows

A view is recomputed every time it's read, so it always reflects the current data:

```sql
BEGIN;
INSERT INTO orders VALUES (200, 5, '2026-08-01', 'paid');
INSERT INTO order_items VALUES (200, 4, 1, 15900);

SELECT order_id, total_cents FROM paid_order_totals WHERE order_id = 200;

ROLLBACK;

SELECT COUNT(*) AS rows_for_200 FROM paid_order_totals WHERE order_id = 200;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*

| order_id | total_cents |
|---|---|
| 200 | 15900 |

| rows_for_200 |
|---|
| 0 |
<!-- /result -->

That's the difference from a **snapshot table** (`CREATE TABLE … AS SELECT`), which copies the rows once and then goes stale. The Advanced level compares both. A view on a big join is only as fast as the join itself; PostgreSQL's `MATERIALIZED VIEW` stores rows and refreshes on demand.

In SQLite, views are read-only: you can't `INSERT` into one without an `INSTEAD OF` trigger.

## 3. Transactions: all or nothing

A transaction makes several writes behave like one. Moving stock from one product to another, or recording a payment *and* marking the order paid, must not stop half-way.

```sql
BEGIN;
INSERT INTO orders VALUES (201, 6, '2026-08-02', 'pending');
INSERT INTO order_items VALUES (201, 1, 1, 1200);
UPDATE orders SET status = 'paid' WHERE order_id = 201;
INSERT INTO payments VALUES (95, 201, 1200, 'card', '2026-08-02');
COMMIT;

SELECT o.order_id, o.status, p.amount_cents
FROM orders o JOIN payments p ON p.order_id = o.order_id
WHERE o.order_id = 201;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*

*Rows changed: 1*

*Rows changed: 1*

| order_id | status | amount_cents |
|---|---|---|
| 201 | paid | 1200 |
<!-- /result -->

If any statement fails (a constraint, a crash, a lost connection), `ROLLBACK` (or the database itself, on a crash) undoes **all** of them. Nobody ever sees a paid order without its payment.

## 4. Savepoints: undo part of the work

A `SAVEPOINT` marks a point inside a transaction. `ROLLBACK TO name` undoes everything after it **but keeps the transaction open**; `RELEASE name` forgets the mark.

```sql
BEGIN;
UPDATE products SET unit_price_cents = 1300 WHERE product_id = 1;

SAVEPOINT risky_change;
UPDATE products SET unit_price_cents = 0 WHERE category_id = 2;
SELECT COUNT(*) AS free_products FROM products WHERE unit_price_cents = 0;
ROLLBACK TO risky_change;
RELEASE risky_change;

COMMIT;

SELECT product_id, unit_price_cents FROM products WHERE product_id IN (1, 2, 6) ORDER BY product_id;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 4*

| free_products |
|---|
| 4 |

| product_id | unit_price_cents |
|---|---|
| 1 | 1300 |
| 2 | 250 |
| 6 | 450 |
<!-- /result -->

The first update (product 1 → 1300) survived; the risky one was undone. Savepoints are how applications implement "try this step, and if it fails, carry on without it", and they can nest.

## 5. What do other connections see?

While a transaction is open, its changes are **invisible** to other connections until `COMMIT`. Two consequences matter in practice:

- **Keep transactions short.** In SQLite, one writer at a time holds the write lock; other writers wait (`database is locked`). In PostgreSQL, long transactions block clean-up and can hold row locks that stall other requests.
- **Read, then write, can race.** Two requests that both read "stock = 1" and both write "stock = 0" sell the same item twice. The fix is to make the write itself conditional (`UPDATE … SET stock = stock - 1 WHERE stock >= 1`) and check the affected row count, or to lock the row. The Advanced level and the [backend lab](../../backend/README.md) go deeper.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Expecting a view to store results | Slow reads of complex views | Snapshot or materialised view, with a refresh plan |
| Two reports re-implementing "revenue" | Different numbers for the same thing | One view as the single definition |
| `ROLLBACK TO` and forgetting `COMMIT` | All work lost when the connection closes | The transaction is still open after `ROLLBACK TO` |
| Long-running transaction | Other writers time out | Keep transactions short; do slow work outside |
| Read-then-write without a condition | Double-spend / overselling under concurrency | Conditional `UPDATE` + check rows changed |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PI17` | **A reusable view.** Create a view named paid_customer_totals with columns customer_id and lifetime_cents: the sum of payments per customer, for customers with payments. The checker reads the view and confirms it is a view, not a table. | script |
| `PI18` | **Undo part of a transaction.** In one transaction: set product 1's price to 0, then undo only that change with a savepoint, then set product 2's price to 300 and commit. The checker reads both prices afterwards. | script |
| `PI46` | **Monthly revenue view.** Create a view monthly_paid_revenue with columns month (ordered_at as YYYY-MM) and revenue_cents (lines of paid orders). The checker reads it, confirms it is a view, then adds a paid sale and reads it again. | script |
| `PI47` | **Record a sale atomically.** In one transaction, record order 300 for customer 2 on '2026-09-01' with status 'paid', one line of product 3 (quantity 2 at 4900 cents), and payment 300 of 9800 cents by card on '2026-09-01'. Commit. | script |

```bash
python tools/practice.py show PI17
python tools/practice.py check PI17
python tools/practice.py hint PI17 1
```
<!-- /exercises -->

Then take the [Intermediate assessment](../ASSESSMENT.md) and run `python tools/verify_level.py intermediate`.

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** A view…

   - **a)** stores a copy of the rows
   - **b)** stores the query and recomputes it when read
   - **c)** is deleted at the end of the statement

**2.** After `ROLLBACK TO my_savepoint`, the transaction is…

   - **a)** still open
   - **b)** committed
   - **c)** rolled back completely

**3.** Why should transactions be short?

   - **a)** They expire after one second
   - **b)** Open transactions hold locks that make other writers wait
   - **c)** SQLite limits statements per transaction

**4.** Two requests read stock = 1 and both write stock = 0. What prevents selling the item twice?

   - **a)** A view
   - **b)** A conditional UPDATE … WHERE stock >= 1 and checking rows changed
   - **c)** Using UNION ALL

```bash
python tools/quiz.py intermediate/09 1 b      # question 1, answer b
python tools/quiz.py intermediate/09           # list the questions
```
<!-- /quiz -->

## Summary

- A view is a named, stored query; it returns current data every time it's read.
- Transactions make several writes atomic: all of them happen, or none.
- `SAVEPOINT` / `ROLLBACK TO` undo part of a transaction and keep it open.
- Uncommitted changes are invisible to others. Keep transactions short and make writes conditional.

**Next level:** [Advanced · 00 Indexes and query plans](../../advanced/lessons/00_indexes_explain.md)
