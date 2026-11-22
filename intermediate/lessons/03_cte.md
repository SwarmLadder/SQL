# 03 · Common table expressions

> **You will learn** to name query steps with `WITH`, to build a report as a pipeline of small stages each with one grain, to use one CTE several times, and to test a long query stage by stage.
> **Time:** about 45 minutes · **Before this:** [01 · Subqueries](01_subqueries.md)

Lesson 00's fan-out fix nested two derived tables inside one `FROM`. It worked, but it reads inside-out. A **common table expression** (CTE) gives each step a name and puts the steps in reading order, top to bottom.

**Run the whole lesson:** `python tools/run_sql.py intermediate/lessons/03_cte.sql`

## 1. WITH name AS (…)

```sql
WITH paid_orders AS (
  SELECT order_id, customer_id, ordered_at
  FROM orders
  WHERE status = 'paid'
)
SELECT customer_id, COUNT(*) AS paid_orders, MAX(ordered_at) AS last_paid_order
FROM paid_orders
GROUP BY customer_id
ORDER BY customer_id;
```

<!-- result -->
| customer_id | paid_orders | last_paid_order |
|---|---|---|
| 1 | 2 | 2026-03-02 |
| 2 | 1 | 2026-02-05 |
| 3 | 1 | 2026-07-08 |
| 4 | 1 | 2026-04-06 |
| 6 | 1 | 2026-05-04 |
| 7 | 1 | 2026-06-02 |
| 8 | 1 | 2026-06-21 |
<!-- /result -->

- The CTE exists only for **this one statement**. The next statement can't see it.
- Use it like a table: select from it, join it, filter it.
- SQLite and PostgreSQL may inline a CTE or compute it once. Write CTEs for **clarity**; don't assume they make a query faster or slower.

## 2. A pipeline of stages

Separate CTEs with commas. Each stage can use the ones before it. Here is lesson 00's report as a pipeline, one grain per stage:

```sql
WITH item_totals AS (          -- one row per order
  SELECT order_id, SUM(quantity * unit_price_cents) AS items_cents
  FROM order_items
  GROUP BY order_id
),
payment_totals AS (            -- one row per order that has payments
  SELECT order_id, SUM(amount_cents) AS paid_cents
  FROM payments
  GROUP BY order_id
),
paid_order_report AS (         -- one row per paid order
  SELECT o.order_id, o.customer_id, t.items_cents,
         COALESCE(p.paid_cents, 0) AS paid_cents
  FROM orders o
  JOIN item_totals t ON t.order_id = o.order_id
  LEFT JOIN payment_totals p ON p.order_id = o.order_id
  WHERE o.status = 'paid'
)
SELECT customer_id,
       COUNT(*)         AS paid_orders,
       SUM(items_cents) AS items_cents,
       SUM(paid_cents)  AS paid_cents
FROM paid_order_report
GROUP BY customer_id
ORDER BY items_cents DESC, customer_id;
```

<!-- result -->
| customer_id | paid_orders | items_cents | paid_cents |
|---|---|---|---|
| 1 | 2 | 25550 | 25550 |
| 4 | 1 | 19600 | 19600 |
| 8 | 1 | 16150 | 16150 |
| 3 | 1 | 13800 | 13800 |
| 7 | 1 | 11350 | 11350 |
| 6 | 1 | 10100 | 10100 |
| 2 | 1 | 5400 | 5400 |
<!-- /result -->

Comment each stage with its grain. Reviewers can then check every step on its own: "is `item_totals` really one row per order?"

## 3. Reusing a stage

A CTE can be referenced more than once. "Months whose paid revenue was above the average month":

```sql
WITH monthly AS (
  SELECT SUBSTR(o.ordered_at, 1, 7) AS month,
         SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM orders o
  JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY month
)
SELECT month, revenue_cents,
       (SELECT ROUND(AVG(revenue_cents)) FROM monthly) AS avg_month_cents
FROM monthly
WHERE revenue_cents > (SELECT AVG(revenue_cents) FROM monthly)
ORDER BY month;
```

<!-- result -->
| month | revenue_cents | avg_month_cents |
|---|---|---|
| 2026-03 | 22400 | 14564.0 |
| 2026-04 | 19600 | 14564.0 |
| 2026-06 | 27500 | 14564.0 |
<!-- /result -->

Without the CTE, the monthly aggregation would have to be written three times.

## 4. Debugging stage by stage

When a long query gives a wrong number, don't stare at the whole thing. Replace the final `SELECT` with `SELECT * FROM <stage>` and check each stage's row count and grain:

```sql
WITH item_totals AS (
  SELECT order_id, SUM(quantity * unit_price_cents) AS items_cents
  FROM order_items
  GROUP BY order_id
)
SELECT COUNT(*) AS rows_in_stage,
       COUNT(DISTINCT order_id) AS distinct_orders
FROM item_totals;
```

<!-- result -->
| rows_in_stage | distinct_orders |
|---|---|
| 11 | 11 |
<!-- /result -->

If `rows_in_stage` and `distinct_orders` differ, the stage isn't at the grain you think it is.

## 5. CTE or subquery?

They are equivalent in power for non-recursive queries. Prefer a CTE when:

- a step is used more than once;
- the query has more than two levels of nesting;
- you want to name and comment the grain of each step.

A short scalar subquery in `WHERE` is often clearer left inline. `WITH RECURSIVE`, a CTE that refers to itself, is in the Advanced level.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Expecting a CTE to exist in the next statement | `no such table` | CTEs live for one statement; use a view (lesson 09) to reuse |
| A trailing comma after the last CTE | Syntax error | Commas only *between* CTEs |
| A stage at the wrong grain | Fan-out returns, one stage later | Comment and check each stage's grain |
| Reusing a name in two CTEs | Error or confusing shadowing | Unique, descriptive names |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PI01` | **Customer lifetime totals.** Using a CTE, return customer_id, full_name, lifetime_cents (sum of payments.amount_cents) for customers with at least one payment. Sort by lifetime_cents descending, then customer_id. | query |
| `PI07` | **Two-stage order report.** Stage 1: total each paid order (sum of quantity × unit_price_cents). Stage 2: per customer, return customer_id, paid_orders (count) and avg_order_cents (average order total rounded to the nearest cent). Sort by customer_id. | query |
| `PI28` | **Months above average.** With a CTE of monthly paid revenue (lines of paid orders, month of ordered_at as YYYY-MM), return month, revenue_cents for months whose revenue is above the average month. Sort by month. | query |
| `PI29` | **Big spenders.** Using CTEs, return customer_id, full_name, revenue_cents (paid order lines) for customers whose paid revenue is at least 15000 cents, sorted by revenue_cents descending, then customer_id. | query |

```bash
python tools/practice.py show PI01
python tools/practice.py check PI01
python tools/practice.py hint PI01 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** How long does a CTE exist?

   - **a)** Until the connection closes
   - **b)** For the one statement it's defined in
   - **c)** Forever, like a table

**2.** How are several CTEs written?

   - **a)** WITH a AS (…), b AS (…) SELECT …
   - **b)** WITH a AS (…) WITH b AS (…) SELECT …
   - **c)** WITH (a, b) AS (…)

**3.** Do CTEs make queries faster?

   - **a)** Always
   - **b)** Never
   - **c)** Not necessarily: write them for clarity

**4.** A stage should be one row per order, but `COUNT(*)` ≠ `COUNT(DISTINCT order_id)`. What does that mean?

   - **a)** The stage is not at the grain you think
   - **b)** Nothing, that's normal
   - **c)** The data is corrupted

```bash
python tools/quiz.py intermediate/03 1 b      # question 1, answer b
python tools/quiz.py intermediate/03           # list the questions
```
<!-- /quiz -->

## Summary

- `WITH name AS (…)` names a step; several steps are separated by commas.
- Each stage should have one clearly stated grain.
- A CTE can be used many times in the same statement, but only in that statement.
- Debug a pipeline by selecting from one stage at a time.

**Next:** [04 · CASE and conditional aggregation](04_case_conditional.md)
