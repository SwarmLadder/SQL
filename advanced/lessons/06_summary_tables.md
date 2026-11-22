# 06 · Summary tables and freshness

> **You will learn** when a stored summary beats a view, to build a summary table with a unique key, to refresh it fully and atomically or incrementally with an upsert, to measure how stale it is, and to reconcile it against the source.
> **Time:** about 55 minutes · **Before this:** [04 · UPSERT and idempotency keys](04_upsert_idempotency.md), [Intermediate 09 · Views](../../intermediate/lessons/09_views_savepoints.md)

A view recomputes on every read. With millions of order lines, a dashboard that re-aggregates everything on each page load is slow and expensive. A **summary table** stores the result, at the price of being **stale** between refreshes. Managing that price is the whole subject.

**Run the whole lesson:** `python tools/run_sql.py advanced/lessons/06_summary_tables.sql`

## 1. View vs snapshot

```sql
CREATE VIEW live_category_revenue AS
SELECT p.category_id, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
FROM order_items i
JOIN orders o   ON o.order_id = i.order_id
JOIN products p ON p.product_id = i.product_id
WHERE o.status = 'paid'
GROUP BY p.category_id;

CREATE TABLE category_revenue_snapshot AS
SELECT * FROM live_category_revenue;

-- A new paid sale of a Keyboard (category 3) arrives.
INSERT INTO orders VALUES (600, 2, '2026-08-05', 'paid');
INSERT INTO order_items VALUES (600, 4, 1, 15900);

SELECT l.category_id, l.revenue_cents AS live_cents, s.revenue_cents AS snapshot_cents
FROM live_category_revenue l
JOIN category_revenue_snapshot s ON s.category_id = l.category_id
ORDER BY l.category_id;
```

<!-- result -->
*Rows changed: 1*

| category_id | live_cents | snapshot_cents |
|---|---|---|
| 1 | 20800 | 20800 |
| 2 | 9650 | 9650 |
| 3 | 60700 | 44800 |
| 4 | 26700 | 26700 |
<!-- /result -->

The view sees the new sale; the snapshot doesn't. `CREATE TABLE … AS SELECT` copies rows **once**. It has no constraints, no key and no automatic refresh.

## 2. Design a real summary table

Give it the grain as a **primary key**, explicit types, and a timestamp of when it was built:

```sql
CREATE TABLE customer_month_revenue (
  customer_id   INTEGER NOT NULL,
  month         TEXT    NOT NULL,
  revenue_cents INTEGER NOT NULL,
  refreshed_at  TEXT    NOT NULL,
  PRIMARY KEY (customer_id, month)
);
```

<!-- result -->
*Done (no rows returned).*
<!-- /result -->

The primary key documents the grain ("one row per customer and month"), prevents duplicates, and makes upserts possible.

## 3. Full refresh, atomically

Rebuild everything inside one transaction. Readers see either the old contents or the new, never an empty or half-filled table:

```sql
BEGIN;
DELETE FROM customer_month_revenue;
INSERT INTO customer_month_revenue (customer_id, month, revenue_cents, refreshed_at)
SELECT o.customer_id, strftime('%Y-%m', o.ordered_at), SUM(i.quantity * i.unit_price_cents), '2026-08-06T02:00'
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.customer_id, strftime('%Y-%m', o.ordered_at);
COMMIT;

SELECT customer_id, month, revenue_cents FROM customer_month_revenue ORDER BY month, customer_id;
```

<!-- result -->
*Rows changed: 0*

*Rows changed: 9*

| customer_id | month | revenue_cents |
|---|---|---|
| 1 | 2026-01 | 3150 |
| 2 | 2026-02 | 5400 |
| 1 | 2026-03 | 22400 |
| 4 | 2026-04 | 19600 |
| 6 | 2026-05 | 10100 |
| 7 | 2026-06 | 11350 |
| 8 | 2026-06 | 16150 |
| 3 | 2026-07 | 13800 |
| 2 | 2026-08 | 15900 |
<!-- /result -->

Full refreshes are simple and self-healing (any earlier mistake is overwritten), but their cost grows with the whole history.

## 4. Incremental refresh with an upsert

Recompute only the groups that may have changed (here, one month) and upsert them:

```sql
INSERT INTO orders VALUES (601, 2, '2026-08-20', 'paid');
INSERT INTO order_items VALUES (601, 1, 2, 1200);

INSERT INTO customer_month_revenue (customer_id, month, revenue_cents, refreshed_at)
SELECT o.customer_id, strftime('%Y-%m', o.ordered_at), SUM(i.quantity * i.unit_price_cents), '2026-08-21T02:00'
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid' AND o.ordered_at >= '2026-08-01' AND o.ordered_at < '2026-09-01'
GROUP BY o.customer_id, strftime('%Y-%m', o.ordered_at)
ON CONFLICT(customer_id, month) DO UPDATE
  SET revenue_cents = excluded.revenue_cents,
      refreshed_at  = excluded.refreshed_at;

SELECT customer_id, month, revenue_cents, refreshed_at
FROM customer_month_revenue WHERE month = '2026-08';
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*

*Rows changed: 1*

| customer_id | month | revenue_cents | refreshed_at |
|---|---|---|---|
| 2 | 2026-08 | 18300 | 2026-08-21T02:00 |
<!-- /result -->

The group is **recomputed** (`= excluded.revenue_cents`), not incremented. Re-running the refresh gives the same result, so the refresh is idempotent. Two gaps remain: a group whose rows all disappear (an order cancelled after the fact) keeps its old row, and late-arriving data for an older month is missed. Production systems refresh a window ("the last 3 months") and run a periodic full rebuild.

## 5. Freshness and reconciliation

Every summary should answer "how old am I?" and "am I right?":

```sql
SELECT MAX(refreshed_at) AS last_refresh FROM customer_month_revenue;
```

<!-- result -->
| last_refresh |
|---|
| 2026-08-21T02:00 |
<!-- /result -->

```sql
WITH live AS (
  SELECT o.customer_id, strftime('%Y-%m', o.ordered_at) AS month,
         SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM orders o JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.customer_id, month
)
SELECT COALESCE(l.customer_id, s.customer_id) AS customer_id,
       COALESCE(l.month, s.month) AS month,
       l.revenue_cents AS live_cents, s.revenue_cents AS summary_cents
FROM live l
FULL JOIN customer_month_revenue s ON s.customer_id = l.customer_id AND s.month = l.month
WHERE l.revenue_cents IS NOT s.revenue_cents;
```

<!-- result -->
| customer_id | month | live_cents | summary_cents |
|---|---|---|---|
| *(no rows)* |  |  |  |
<!-- /result -->

An empty result means the summary agrees with the source. `IS NOT` is the NULL-safe "different" (true when exactly one side is NULL), and `FULL JOIN` (SQLite 3.39+) finds rows missing on either side. Run this check after each refresh, or on a schedule with an alert.

## 6. Choosing a strategy

| Approach | Freshness | Read cost | Write/refresh cost | Use when |
|---|---|---|---|---|
| View | always current | full query each read | none | data is small or reads are rare |
| Full rebuild | as of last run | tiny | grows with history | nightly reports, self-healing |
| Incremental upsert | as of last run | tiny | proportional to changes | large history, frequent refresh |
| Trigger-maintained | immediate | tiny | on every write | small, simple aggregates (lesson 05) |
| PostgreSQL materialised view | as of `REFRESH` | tiny | full rebuild (`CONCURRENTLY` keeps it readable) | when the database manages it for you |

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| `CREATE TABLE AS SELECT` and calling it done | No key, duplicates on re-run, no refresh | Explicit table with a primary key + refresh job |
| `DELETE` then `INSERT` outside a transaction | Dashboards briefly empty | One transaction |
| Incrementing on refresh | Re-runs double-count | Recompute the group (`= excluded.value`) |
| Never reconciling | Silent drift | Scheduled source vs summary check |
| No `refreshed_at` | Nobody knows how stale it is | Store and display it |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PA13` | **Snapshot that goes stale.** Create a table (not a view) category_revenue_snapshot(category_id, revenue_cents) holding paid revenue per category (quantity × unit_price_cents of order lines in paid orders), for categories with revenue. The checker then records a new paid sale and reads your snapshot, which should not change until it is rebuilt. | script |
| `PA33` | **A keyed summary table.** Create customer_month_revenue(customer_id INTEGER NOT NULL, month TEXT NOT NULL, revenue_cents INTEGER NOT NULL, PRIMARY KEY (customer_id, month)) and fill it with paid revenue (order lines of paid orders) per customer and month of ordered_at (YYYY-MM). The checker then tries to insert a duplicate group. | script |

```bash
python tools/practice.py show PA13
python tools/practice.py check PA13
python tools/practice.py hint PA13 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** After a new sale, a view and a snapshot table…

   - **a)** both show it
   - **b)** the view shows it, the snapshot doesn't until refreshed
   - **c)** neither shows it

**2.** Why do a full refresh's DELETE and INSERT go in one transaction?

   - **a)** Readers never see an empty or half-filled table
   - **b)** It's required syntax
   - **c)** To make the refresh incremental

**3.** An incremental refresh should set `revenue = excluded.revenue` rather than add to it because…

   - **a)** re-running the refresh must not double-count
   - **b)** addition is slower
   - **c)** SQLite forbids +

**4.** Which operator compares two possibly-NULL values as 'different'?

   - **a)** <>
   - **b)** IS NOT
   - **c)** !=

```bash
python tools/quiz.py advanced/06 1 b      # question 1, answer b
python tools/quiz.py advanced/06           # list the questions
```
<!-- /quiz -->

## Summary

- Views are always fresh but recompute; summary tables are fast but stale.
- Key the summary by its grain, and record when it was refreshed.
- Full refresh in one transaction; incremental refresh by recomputing changed groups with an upsert.
- Reconcile against the source with a NULL-safe full comparison.

**Next:** [07 · Constraints and schema changes](07_constraints_migrations.md)
