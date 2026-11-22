# 09 · Advanced reporting capstone

> **You will build** a finance-grade report end to end: definitions, a reconciliation of orders against payments, revenue shares by category, a ranked customer list, the indexes the report needs (with plans), and a verification suite. It's everything from the three levels, used together.
> **Time:** about 90 minutes · **Before this:** Advanced lessons [00](00_indexes_explain.md)–[08](08_null_semantics.md)

Finance asks: *"Before we close the month, show us that every paid order was paid correctly, where the revenue came from, and who our top customers are. And prove the numbers."*

**Run the whole lesson:** `python tools/run_sql.py advanced/lessons/09_advanced_capstone.sql`

## 1. Definitions

| Term | Definition |
|---|---|
| Item value | `quantity × unit_price_cents` of an order's lines |
| Received | sum of `payments.amount_cents` for the order |
| Paid order | `orders.status = 'paid'` |
| Reconciled | paid order whose received amount equals its item value |
| Revenue | item value of paid orders |
| Grain | one row per order (reconciliation); per category; per customer |

## 2. Reconciliation: one row per order, one flag

Pre-aggregate items and payments separately (no fan-out), keep **every** order, and classify it. The `CASE` branches go from most to least specific:

```sql
WITH items AS (
  SELECT order_id, SUM(quantity * unit_price_cents) AS item_cents
  FROM order_items GROUP BY order_id
), received AS (
  SELECT order_id, SUM(amount_cents) AS received_cents, COUNT(*) AS payments
  FROM payments GROUP BY order_id
)
SELECT o.order_id, o.status,
       COALESCE(i.item_cents, 0)     AS item_cents,
       COALESCE(r.received_cents, 0) AS received_cents,
       CASE
         WHEN o.status = 'paid' AND r.order_id IS NULL                 THEN 'missing_payment'
         WHEN o.status = 'paid' AND r.received_cents <> i.item_cents   THEN 'amount_mismatch'
         WHEN o.status = 'paid'                                         THEN 'ok'
         WHEN r.order_id IS NOT NULL                                    THEN 'unexpected_payment'
         ELSE 'not_due'
       END AS flag
FROM orders o
LEFT JOIN items i    ON i.order_id = o.order_id
LEFT JOIN received r ON r.order_id = o.order_id
ORDER BY o.order_id;
```

<!-- result -->
| order_id | status | item_cents | received_cents | flag |
|---|---|---|---|---|
| 101 | paid | 3150 | 3150 | ok |
| 102 | paid | 5400 | 5400 | ok |
| 103 | paid | 22400 | 22400 | ok |
| 104 | pending | 5500 | 0 | not_due |
| 105 | paid | 19600 | 19600 | ok |
| 106 | cancelled | 4900 | 0 | not_due |
| 107 | paid | 10100 | 10100 | ok |
| 108 | pending | 2500 | 0 | not_due |
| 109 | paid | 11350 | 11350 | ok |
| 110 | paid | 16150 | 16150 | ok |
| 111 | paid | 13800 | 13800 | ok |
<!-- /result -->

All paid orders reconcile today. To see the flags work, break the data inside a transaction:

```sql
BEGIN;
UPDATE payments SET amount_cents = amount_cents - 100 WHERE payment_id = 1;      -- short payment
INSERT INTO payments VALUES (99, 104, 5500, 'card', '2026-03-12');               -- pending order paid
DELETE FROM payments WHERE payment_id = 8;                                         -- paid order, no payment

WITH items AS (
  SELECT order_id, SUM(quantity * unit_price_cents) AS item_cents FROM order_items GROUP BY order_id
), received AS (
  SELECT order_id, SUM(amount_cents) AS received_cents FROM payments GROUP BY order_id
)
SELECT o.order_id, o.status, i.item_cents, COALESCE(r.received_cents, 0) AS received_cents,
       CASE
         WHEN o.status = 'paid' AND r.order_id IS NULL               THEN 'missing_payment'
         WHEN o.status = 'paid' AND r.received_cents <> i.item_cents THEN 'amount_mismatch'
         WHEN o.status = 'paid'                                       THEN 'ok'
         WHEN r.order_id IS NOT NULL                                  THEN 'unexpected_payment'
         ELSE 'not_due'
       END AS flag
FROM orders o
LEFT JOIN items i    ON i.order_id = o.order_id
LEFT JOIN received r ON r.order_id = o.order_id
WHERE o.order_id IN (101, 104, 111)
ORDER BY o.order_id;

ROLLBACK;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*

*Rows changed: 1*

| order_id | status | item_cents | received_cents | flag |
|---|---|---|---|---|
| 101 | paid | 3150 | 3050 | amount_mismatch |
| 104 | pending | 5500 | 5500 | unexpected_payment |
| 111 | paid | 13800 | 0 | missing_payment |
<!-- /result -->

A reconciliation that has never been seen to fail hasn't been tested.

## 3. Revenue by category, with shares

```sql
WITH category_revenue AS (
  SELECT c.category_name, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM order_items i
  JOIN orders o     ON o.order_id = i.order_id AND o.status = 'paid'
  JOIN products p   ON p.product_id = i.product_id
  JOIN categories c ON c.category_id = p.category_id
  GROUP BY c.category_id, c.category_name
)
SELECT category_name, revenue_cents,
       ROUND(100.0 * revenue_cents / SUM(revenue_cents) OVER (), 1) AS share_pct,
       SUM(revenue_cents) OVER (ORDER BY revenue_cents DESC, category_name) AS cumulative_cents
FROM category_revenue
ORDER BY revenue_cents DESC, category_name;
```

<!-- result -->
| category_name | revenue_cents | share_pct | cumulative_cents |
|---|---|---|---|
| Electronics | 44800 | 43.9 | 44800 |
| Home | 26700 | 26.2 | 71500 |
| Books | 20800 | 20.4 | 92300 |
| Stationery | 9650 | 9.5 | 101950 |
<!-- /result -->

Rounded shares may not add up to exactly 100.0. If finance needs that, show one more decimal or adjust the largest share, and say so in the report.

## 4. Top customers

```sql
WITH customer_revenue AS (
  SELECT o.customer_id, SUM(i.quantity * i.unit_price_cents) AS revenue_cents,
         COUNT(DISTINCT o.order_id) AS paid_orders
  FROM orders o JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.customer_id
)
SELECT DENSE_RANK() OVER (ORDER BY r.revenue_cents DESC) AS rank,
       c.full_name, c.city, r.paid_orders, r.revenue_cents
FROM customer_revenue r
JOIN customers c ON c.customer_id = r.customer_id
ORDER BY rank, c.customer_id
LIMIT 5;
```

<!-- result -->
| rank | full_name | city | paid_orders | revenue_cents |
|---|---|---|---|---|
| 1 | Ana Ionescu | Bucharest | 2 | 25550 |
| 2 | Darius Ene | Timișoara | 1 | 19600 |
| 3 | Horia Vlad | Oradea | 1 | 16150 |
| 4 | Carmen Radu | Iași | 1 | 13800 |
| 5 | Gabriela Dinu | Sibiu | 1 | 11350 |
<!-- /result -->

## 5. Make it fast: indexes with evidence

The report filters orders by status and joins lines and payments by `order_id`. `order_items` already has its primary key `(order_id, product_id)`; `payments.order_id` has **no** index:

```sql
EXPLAIN QUERY PLAN
SELECT order_id, SUM(amount_cents) FROM payments WHERE order_id = 101;
```

<!-- result -->
| id | parent | notused | detail |
|---|---|---|---|
| 4 | 0 | 216 | SCAN payments |
<!-- /result -->

```sql
CREATE INDEX idx_payments_order ON payments(order_id, amount_cents);

EXPLAIN QUERY PLAN
SELECT order_id, SUM(amount_cents) FROM payments WHERE order_id = 101;
```

<!-- result -->
| id | parent | notused | detail |
|---|---|---|---|
| 4 | 0 | 53 | SEARCH payments USING COVERING INDEX idx_payments_order (order_id=?) |
<!-- /result -->

On millions of rows, also consider: an index on `orders(status, ordered_at)` for month-close filters, running the report from a **summary table** refreshed nightly (lesson 06), and a read replica so the report doesn't compete with checkout traffic.

## 6. Verification suite

Each check returns **zero rows** when the report is correct. Run them all after every change:

```sql
-- (a) Revenue by category adds up to total paid item value.
SELECT 'category total' AS check_name
WHERE (SELECT SUM(i.quantity * i.unit_price_cents) FROM order_items i JOIN orders o ON o.order_id = i.order_id WHERE o.status = 'paid')
   <> (SELECT SUM(i.quantity * i.unit_price_cents) FROM order_items i
       JOIN orders o ON o.order_id = i.order_id AND o.status = 'paid'
       JOIN products p ON p.product_id = i.product_id
       JOIN categories c ON c.category_id = p.category_id)
UNION ALL
-- (b) Every order appears exactly once in the reconciliation.
SELECT 'reconciliation rows'
WHERE (SELECT COUNT(*) FROM orders)
   <> (SELECT COUNT(*) FROM orders o LEFT JOIN (SELECT order_id FROM payments GROUP BY order_id) r ON r.order_id = o.order_id)
UNION ALL
-- (c) Received money equals the sum of payments (nothing lost or duplicated).
SELECT 'payments total'
WHERE (SELECT SUM(amount_cents) FROM payments)
   <> (SELECT SUM(received_cents) FROM (SELECT order_id, SUM(amount_cents) AS received_cents FROM payments GROUP BY order_id));
```

<!-- result -->
*Done (no rows returned).*
<!-- /result -->

No rows: every check passes. In a real project, these become automated tests that run in CI against a fixture database, like the checkers in this course.

## Common mistakes

| Mistake | What happens | Fix |
|---|---|---|
| Joining items and payments before summing | Mismatches everywhere (fan-out) | Pre-aggregate each to one row per order |
| `INNER JOIN` to payments | Orders without payments vanish instead of being flagged | `LEFT JOIN` and test the key for NULL |
| `CASE` branches in the wrong order | Missing payments reported as mismatches | Most specific branch first |
| Rounded shares used in further maths | Totals drift from 100% | Keep exact values; round only for display |
| Verification never run on broken data | Checks that can't fail | Break the data in a transaction and watch them fire |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PA18` | **Order-to-payment reconciliation.** For every order return order_id, status, items_cents, paid_cents (0 if none) and flag: 'missing_payment' (paid, no payment), 'mismatch' (paid, amounts differ), 'ok' (paid, amounts match), 'unexpected_payment' (not paid but has a payment), 'not_due' otherwise. Sort by order_id. | query |
| `PA19` | **Top customers with DENSE_RANK.** Return customer_id, lifetime_cents (sum of payments) and spend_rank (DENSE_RANK, highest spender = 1) for customers with payments. Sort by spend_rank, then customer_id. | query |
| `PA20` | **Revenue report checklist.** Write the checklist you would run before trusting a monthly revenue report: which statuses count, refunds and partial payments, time zones and month boundaries, join fan-out, NULLs, currency units, and how you would cross-check the total against an independent source. | written ✍️ |
| `PA38` | **Category revenue shares.** Return category_name, revenue_cents (lines of paid orders) and share_pct (percentage of all paid revenue, rounded to 1 decimal) for categories with paid revenue, sorted by revenue_cents descending, then category_name. | query |

```bash
python tools/practice.py show PA18
python tools/practice.py check PA18
python tools/practice.py hint PA18 1
```
<!-- /exercises -->

Then take the [Advanced assessment](../ASSESSMENT.md) and run `python tools/verify_level.py advanced`.

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** Why are items and payments aggregated in separate CTEs in the reconciliation?

   - **a)** To avoid fan-out between two one-to-many tables
   - **b)** CTEs are faster
   - **c)** SQLite requires it

**2.** Why does the CASE check 'missing_payment' before 'amount_mismatch'?

   - **a)** Branches are tested in order; the most specific must come first
   - **b)** Alphabetical order
   - **c)** It doesn't matter

**3.** A verification check "returns zero rows when correct". Why also run it on deliberately broken data?

   - **a)** To prove the check can fail at all
   - **b)** To make it faster
   - **c)** To fill the cache

```bash
python tools/quiz.py advanced/09 1 b      # question 1, answer b
python tools/quiz.py advanced/09           # list the questions
```
<!-- /quiz -->

## Summary

- Write definitions first; they decide the filters and the grain.
- Reconcile with pre-aggregated, left-joined facts and an ordered `CASE`.
- Show shares with `SUM() OVER ()`, rankings with `DENSE_RANK`.
- Justify indexes with before/after plans.
- Ship a verification suite that returns zero rows when the report is right, and test it on broken data.

**You've finished the course.** Next: the [backend engineering lab](../../backend/README.md), the [PostgreSQL labs](../postgresql/README.md) and the [mock interviews](../../interview/MOCK_INTERVIEWS.md).
