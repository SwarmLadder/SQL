# 05 · GROUP BY and HAVING

> **You will learn** to compute aggregates per group with `GROUP BY`, to group by several columns and by expressions such as a month, to filter groups with `HAVING`, and to name the **grain** of a result.
> **Time:** about 45 minutes · **Before this:** [04 · COUNT, SUM, MIN, MAX, AVG](04_aggregates.md)

Lesson 04 collapsed a whole table into one row. Most reports want one row **per something**: per status, per customer, per month. `GROUP BY` splits rows into groups first and then runs the aggregates once per group.

**Run the whole lesson:** `python tools/run_sql.py basics/lessons/05_group_by_having.sql`

## 1. One row per group

```sql
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY status;
```

<!-- result -->
| status | order_count |
|---|---|
| cancelled | 1 |
| paid | 8 |
| pending | 2 |
<!-- /result -->

Picture it in three steps: the database takes the eleven orders, sorts them into three piles by `status`, and runs `COUNT(*)` on each pile.

**The golden rule:** every column in the `SELECT` list must either appear in `GROUP BY` or be inside an aggregate. A plain column that is not grouped has many values per group, so the database can't know which one to show.

## 2. Grain: what one row means

The **grain** of a result is what one row represents. Say it out loud before you write a report: "one row per customer", "one row per month and payment method". The `GROUP BY` columns *are* the grain.

```sql
SELECT customer_id,
       COUNT(*)        AS orders,
       MIN(ordered_at) AS first_order,
       MAX(ordered_at) AS last_order
FROM orders
GROUP BY customer_id
ORDER BY customer_id;
```

<!-- result -->
| customer_id | orders | first_order | last_order |
|---|---|---|---|
| 1 | 2 | 2026-01-12 | 2026-03-02 |
| 2 | 2 | 2026-02-05 | 2026-05-14 |
| 3 | 2 | 2026-03-12 | 2026-07-08 |
| 4 | 1 | 2026-04-06 | 2026-04-06 |
| 5 | 1 | 2026-04-15 | 2026-04-15 |
| 6 | 1 | 2026-05-04 | 2026-05-04 |
| 7 | 1 | 2026-06-02 | 2026-06-02 |
| 8 | 1 | 2026-06-21 | 2026-06-21 |
<!-- /result -->

Group by several columns for a finer grain. Each distinct *combination* becomes a group:

```sql
SELECT customer_id, status, COUNT(*) AS orders
FROM orders
WHERE customer_id IN (1, 2, 3)
GROUP BY customer_id, status
ORDER BY customer_id, status;
```

<!-- result -->
| customer_id | status | orders |
|---|---|---|
| 1 | paid | 2 |
| 2 | paid | 1 |
| 2 | pending | 1 |
| 3 | paid | 1 |
| 3 | pending | 1 |
<!-- /result -->

## 3. Grouping by an expression

You can group by a computed value. `SUBSTR(ordered_at, 1, 7)` turns `2026-03-12` into the month `2026-03`:

```sql
SELECT SUBSTR(ordered_at, 1, 7) AS month,
       COUNT(*) AS orders
FROM orders
GROUP BY month
ORDER BY month;
```

<!-- result -->
| month | orders |
|---|---|
| 2026-01 | 1 |
| 2026-02 | 1 |
| 2026-03 | 2 |
| 2026-04 | 2 |
| 2026-05 | 2 |
| 2026-06 | 2 |
| 2026-07 | 1 |
<!-- /result -->

SQLite (like PostgreSQL and MySQL) lets you write the alias `month` in `GROUP BY`. Some databases require repeating the expression.

## 4. WHERE vs HAVING

- `WHERE` filters **rows**, before grouping. It can't see aggregates.
- `HAVING` filters **groups**, after the aggregates are computed.

"Customers with more than one paid order" needs both: `WHERE` keeps paid orders, `HAVING` keeps the customers whose count is above one.

```sql
SELECT customer_id, COUNT(*) AS paid_orders
FROM orders
WHERE status = 'paid'
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY customer_id;
```

<!-- result -->
| customer_id | paid_orders |
|---|---|
| 1 | 2 |
<!-- /result -->

Putting an aggregate in `WHERE` is an error, because the counts don't exist yet when `WHERE` runs:

```sql error
SELECT customer_id, COUNT(*)
FROM orders
WHERE COUNT(*) > 1
GROUP BY customer_id;
```

<!-- result -->
**Error:** `misuse of aggregate: COUNT()`
<!-- /result -->

**Logical order of a query.** The database evaluates the clauses in this order, which explains most "why can't I use that here?" errors:

| Step | Clause | Can see |
|---:|---|---|
| 1 | `FROM` | tables |
| 2 | `WHERE` | single rows |
| 3 | `GROUP BY` | forms groups |
| 4 | `HAVING` | groups and their aggregates |
| 5 | `SELECT` | computes output columns and aliases |
| 6 | `ORDER BY` | output columns, aliases |
| 7 | `LIMIT` | the sorted output |

## Common mistakes

| Mistake | What happens | Fix |
|---|---|---|
| `SELECT customer_id, ordered_at, COUNT(*) … GROUP BY customer_id` | Error in most databases; an arbitrary date in SQLite | Group by it, or aggregate it (`MAX(ordered_at)`) |
| Aggregate in `WHERE` | `misuse of aggregate` error | Move the condition to `HAVING` |
| Row filter in `HAVING` | Works, but groups first and filters later | Row conditions belong in `WHERE` |
| Grouping by a name instead of an ID | Two customers with the same name merge | Group by the key (and the name, for display) |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PB13` | **Orders by status.** Return status, order_count for each order status, sorted by status. | query |
| `PB14` | **Repeat customers.** Return customer_id, order_count for customers with more than one order (any status), sorted by customer_id. | query |
| `PB15` | **Revenue by payment method.** Return method, paid_cents (sum of amount_cents) for each payment method that has payments, sorted by method. | query |
| `PB39` | **Categories with several products.** Return category_id, product_count for categories that have more than one product (active or not), sorted by category_id. | query |
| `PB40` | **Orders per month.** Return month (ordered_at as YYYY-MM) and order_count (orders of any status) per month, sorted by month. | query |
| `PB41` | **Products that sell in volume.** Return product_id, units (total quantity over all order lines, any status) for products with at least 3 units, sorted by units descending, then product_id. | query |

```bash
python tools/practice.py show PB13
python tools/practice.py check PB13
python tools/practice.py hint PB13 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** Which clause filters groups by their aggregate?

   - **a)** WHERE
   - **b)** HAVING
   - **c)** ORDER BY

**2.** `SELECT status, customer_id, COUNT(*) FROM orders GROUP BY status;` is a problem because…

   - **a)** customer_id is neither grouped nor aggregated
   - **b)** COUNT needs a column
   - **c)** status is text

**3.** The grain of `… GROUP BY customer_id, status` is…

   - **a)** one row per customer
   - **b)** one row per status
   - **c)** one row per customer and status combination

**4.** In which order are these clauses evaluated?

   - **a)** SELECT, WHERE, GROUP BY
   - **b)** WHERE, GROUP BY, HAVING, SELECT
   - **c)** GROUP BY, WHERE, SELECT

```bash
python tools/quiz.py basics/05 1 b      # question 1, answer b
python tools/quiz.py basics/05           # list the questions
```
<!-- /quiz -->

## Summary

- `GROUP BY` makes one result row per group; aggregates run once per group.
- Every selected column is grouped or aggregated.
- The `GROUP BY` columns define the **grain**; name it before you write the query.
- `WHERE` filters rows before grouping; `HAVING` filters groups after.

**Next:** [06 · INNER JOIN relationships](06_joins.md)
