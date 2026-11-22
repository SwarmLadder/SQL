# 00 · Indexes and query plans

> **You will learn** what an index is, how to read SQLite's `EXPLAIN QUERY PLAN` (`SCAN`, `SEARCH`, `COVERING INDEX`, `TEMP B-TREE`), how to design a composite index from a query, why column order matters, what stops an index from being used, and what indexes cost.
> **Time:** about 60 minutes · **Before this:** the [Intermediate level](../../intermediate/README.md)

The sample tables are tiny, so every query is instant. With a million orders the same queries take seconds, unless the database can jump straight to the rows it needs. An **index** makes that possible, and the **query plan** tells you whether it's being used.

**Run the whole lesson:** `python tools/run_sql.py advanced/lessons/00_indexes_explain.sql`

## 1. What an index is

An index is a separate, sorted structure (a B-tree) that maps column values to rows, like the index at the back of a book. Looking up `customer_id = 1` in a sorted structure takes a handful of steps instead of reading every row.

- The **primary key** is always indexed.
- `UNIQUE` constraints create an index automatically.
- Foreign keys are **not** indexed automatically in SQLite or PostgreSQL. You add those yourself.

```sql
SELECT name, tbl_name, sql
FROM sqlite_master
WHERE type = 'index'
ORDER BY tbl_name, name;
```

<!-- result -->
| name | tbl_name | sql |
|---|---|---|
| sqlite_autoindex_categories_1 | categories | *NULL* |
| sqlite_autoindex_customers_1 | customers | *NULL* |
| idx_employees_manager | employees | CREATE INDEX idx_employees_manager ON employees(manager_id) |
| idx_items_product | order_items | CREATE INDEX idx_items_product ON order_items(product_id) |
| sqlite_autoindex_order_items_1 | order_items | *NULL* |
| idx_orders_customer_date | orders | CREATE INDEX idx_orders_customer_date ON orders(customer_id, ordered_at) |
| sqlite_autoindex_products_1 | products | *NULL* |
| sqlite_autoindex_teams_1 | teams | *NULL* |
<!-- /result -->

Indexes named `sqlite_autoindex_…` (with `sql` = NULL) back `UNIQUE` constraints; the others were created in [`data/schema.sql`](../../data/schema.sql).

## 2. Reading EXPLAIN QUERY PLAN

`EXPLAIN QUERY PLAN` shows the strategy SQLite has chosen **without running the query**. The words to look for:

| Plan text | Meaning |
|---|---|
| `SCAN t` | reads every row of `t` |
| `SEARCH t USING INDEX i (col=?)` | jumps into index `i` using `col` |
| `USING COVERING INDEX` | answers from the index alone, never touching the table |
| `USING INTEGER PRIMARY KEY` | direct lookup by rowid |
| `USE TEMP B-TREE FOR ORDER BY` | sorts the result separately, because no index supplies the order |

```sql
EXPLAIN QUERY PLAN
SELECT order_id, ordered_at FROM orders WHERE customer_id = 1 ORDER BY ordered_at;
```

<!-- result -->
| id | parent | notused | detail |
|---|---|---|---|
| 3 | 0 | 55 | SEARCH orders USING COVERING INDEX idx_orders_customer_date (customer_id=?) |
<!-- /result -->

The existing index `idx_orders_customer_date (customer_id, ordered_at)` both finds customer 1's orders and returns them already sorted by date, so no temp B-tree is needed.

```sql
EXPLAIN QUERY PLAN
SELECT customer_id, full_name FROM customers WHERE city = 'Bucharest';
```

<!-- result -->
| id | parent | notused | detail |
|---|---|---|---|
| 2 | 0 | 216 | SCAN customers |
<!-- /result -->

No index on `city`, so this is a full scan. Add one and ask again:

```sql
CREATE INDEX idx_customers_city ON customers(city);

EXPLAIN QUERY PLAN
SELECT customer_id, full_name FROM customers WHERE city = 'Bucharest';
```

<!-- result -->
| id | parent | notused | detail |
|---|---|---|---|
| 3 | 0 | 62 | SEARCH customers USING INDEX idx_customers_city (city=?) |
<!-- /result -->

A plan is a **prediction**, not a measurement. On tiny tables SQLite may still choose a scan, because reading 8 rows is cheaper than using an index. Always check plans on realistic data volumes, and measure the actual time before claiming a speed-up.

## 3. Composite indexes: column order matters

An index on `(a, b)` is sorted by `a`, then by `b` within each `a`. It helps:

- `WHERE a = ?`: yes, a prefix of the index.
- `WHERE a = ? AND b = ?` and `WHERE a = ? ORDER BY b`: yes, fully.
- `WHERE b = ?` alone: **no**, because `b` is only sorted *within* each `a`.

```sql
EXPLAIN QUERY PLAN
SELECT order_id FROM orders WHERE ordered_at >= '2026-06-01';
```

<!-- result -->
| id | parent | notused | detail |
|---|---|---|---|
| 2 | 0 | 213 | SCAN orders USING COVERING INDEX idx_orders_customer_date |
<!-- /result -->

`idx_orders_customer_date` starts with `customer_id`, so SQLite can't *search* it for a date. It reads the **whole** index instead (`SCAN … USING COVERING INDEX`): cheaper than reading the table, but still every entry. The design rule for one query: **equality columns first, then the range or sort column.**

```sql
CREATE INDEX idx_orders_status_date ON orders(status, ordered_at);

EXPLAIN QUERY PLAN
SELECT order_id, ordered_at FROM orders
WHERE status = 'paid' AND ordered_at >= '2026-04-01'
ORDER BY ordered_at;
```

<!-- result -->
| id | parent | notused | detail |
|---|---|---|---|
| 3 | 0 | 47 | SEARCH orders USING COVERING INDEX idx_orders_status_date (status=? AND ordered_at>?) |
<!-- /result -->

## 4. What stops an index from being used

An index on `col` helps when the query compares the **bare column**. Wrapping it in a function or expression hides it:

```sql
EXPLAIN QUERY PLAN
SELECT order_id FROM orders WHERE substr(ordered_at, 1, 7) = '2026-06';
```

<!-- result -->
| id | parent | notused | detail |
|---|---|---|---|
| 2 | 0 | 213 | SCAN orders USING COVERING INDEX idx_orders_customer_date |
<!-- /result -->

```sql
EXPLAIN QUERY PLAN
SELECT order_id FROM orders WHERE status = 'paid' AND ordered_at >= '2026-06-01' AND ordered_at < '2026-07-01';
```

<!-- result -->
| id | parent | notused | detail |
|---|---|---|---|
| 2 | 0 | 47 | SEARCH orders USING COVERING INDEX idx_orders_status_date (status=? AND ordered_at>? AND ordered_at<?) |
<!-- /result -->

The first plan is a `SCAN` (of an index, but of all of it); the second, the same question as a range on the bare column, is a `SEARCH` that touches only June's paid orders. Other index-killers: `LIKE '%word'` (leading wildcard), `col + 0 = ?`, comparing a text column with a number, and `OR` across different columns (sometimes). When you can't rewrite the query, an **expression index** (`CREATE INDEX … ON t(lower(email))`) indexes the computed value.

## 5. Covering indexes

If the index contains every column the query needs, SQLite never reads the table:

```sql
CREATE INDEX idx_items_product_qty ON order_items(product_id, quantity);

EXPLAIN QUERY PLAN
SELECT product_id, SUM(quantity) FROM order_items GROUP BY product_id;
```

<!-- result -->
| id | parent | notused | detail |
|---|---|---|---|
| 6 | 0 | 213 | SCAN order_items USING COVERING INDEX idx_items_product_qty |
<!-- /result -->

Covering indexes are a strong optimisation for hot read paths, at the cost of a bigger index.

## 6. What indexes cost

Every index is a write tax:

- Each `INSERT` and `DELETE` updates **every** index on the table; each `UPDATE` updates the indexes on the changed columns.
- Indexes take disk and memory, often as much as the table itself.
- More indexes give the planner more choices, and occasionally a worse one.

**Good default:** index primary keys (automatic), foreign keys you join or filter on, and the specific columns of your slowest frequent queries, each justified with a plan. "Index every column" is not a strategy.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Index on `(a, b)` for `WHERE b = ?` | Still a `SCAN` | Order columns: equality first, then range/sort |
| Function on the indexed column | `SCAN` despite the index | Rewrite as a range, or an expression index |
| Trusting a plan on tiny data | Different plan in production | Test with realistic volumes; `ANALYZE` updates statistics |
| Indexing everything | Slow writes, bloated storage | Justify each index with a query and a plan |
| Forgetting foreign-key indexes | Slow joins and slow parent deletes | Index FK columns you join on |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PA01` | **Index for a hot query.** The payments screen runs: SELECT payment_id, amount_cents FROM payments WHERE method = 'card' ORDER BY paid_at. Create one index so SQLite can both filter and sort through it (no full scan, no temporary sort). Check your plan with EXPLAIN QUERY PLAN first. | script |
| `PA02` | **The cost of indexes.** Every index speeds up some reads and slows down every write to its table. For the index you created in PA01, list which statements get slower, estimate the storage cost, and describe how you would decide whether to keep it in production. | written ✍️ |
| `PA21` | **Index the pending-orders queue.** An operations screen runs: SELECT order_id, ordered_at FROM orders WHERE status = 'pending' ORDER BY ordered_at. Create one index so the plan searches an index and needs no temporary sort. | script |

```bash
python tools/practice.py show PA01
python tools/practice.py check PA01
python tools/practice.py hint PA01 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** What does `USE TEMP B-TREE FOR ORDER BY` in a plan mean?

   - **a)** The result is sorted separately because no index provides the order
   - **b)** A temporary index was created permanently
   - **c)** The query failed

**2.** An index on (customer_id, ordered_at) helps which filter?

   - **a)** WHERE ordered_at = ?
   - **b)** WHERE customer_id = ? ORDER BY ordered_at
   - **c)** WHERE status = ?

**3.** Why can't `WHERE substr(ordered_at, 1, 7) = '2026-06'` search an index on ordered_at?

   - **a)** The function hides the bare column
   - **b)** substr is slow
   - **c)** Text can't be indexed

**4.** What is the main cost of an index?

   - **a)** Every write must update it, and it takes space
   - **b)** Reads get slower
   - **c)** None

```bash
python tools/quiz.py advanced/00 1 b      # question 1, answer b
python tools/quiz.py advanced/00           # list the questions
```
<!-- /quiz -->

## Summary

- An index is a sorted copy of some columns that lets the database jump to matching rows.
- `EXPLAIN QUERY PLAN`: `SCAN` reads everything, `SEARCH … USING INDEX` jumps, `TEMP B-TREE` sorts separately.
- Composite indexes: equality columns first, then range/sort; usable only by a left prefix.
- Functions on indexed columns hide them. Rewrite as ranges or use expression indexes.
- Every index costs writes and space; add them for real queries, with plans as evidence.

**Next:** [01 · Query rewrites and correct grain](01_query_rewrites.md)
