# 09 · Basics review: order report

> **You will practise** everything from this level on one realistic task: a sales report for the shop's owner. You'll define the terms, build the report step by step, and verify it against an independent total.
> **Time:** about 60 minutes · **Before this:** lessons [00](00_select.md)–[08](08_dml.md)

The owner asks: *"How did we do? Revenue per month, our best customers, our best products, and anything that looks wrong."* Before writing any SQL, a professional pins down what the words mean.

**Run the whole lesson:** `python tools/run_sql.py basics/lessons/09_review.sql`

## 1. Define the terms

| Term | Decision for this report | Why |
|---|---|---|
| Revenue | Sum of `quantity × unit_price_cents` over lines of **paid** orders | Pending orders may never be paid; cancelled ones won't |
| Month | `SUBSTR(ordered_at, 1, 7)` | The order date, not the payment date |
| Money | Integer cents; format as euros only for display | Exact arithmetic (lesson 03) |
| Customer | `customer_id` (names are for display) | Names aren't unique (lesson 06) |

Write such a table for every report. Most "wrong numbers" are disagreements about definitions, not SQL bugs.

## 2. Revenue per month

```sql
SELECT SUBSTR(o.ordered_at, 1, 7) AS month,
       COUNT(DISTINCT o.order_id) AS paid_orders,
       SUM(i.quantity * i.unit_price_cents) AS revenue_cents,
       printf('%.2f', SUM(i.quantity * i.unit_price_cents) / 100.0) AS revenue_eur
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY month
ORDER BY month;
```

<!-- result -->
| month | paid_orders | revenue_cents | revenue_eur |
|---|---|---|---|
| 2026-01 | 1 | 3150 | 31.50 |
| 2026-02 | 1 | 5400 | 54.00 |
| 2026-03 | 1 | 22400 | 224.00 |
| 2026-04 | 1 | 19600 | 196.00 |
| 2026-05 | 1 | 10100 | 101.00 |
| 2026-06 | 2 | 27500 | 275.00 |
| 2026-07 | 1 | 13800 | 138.00 |
<!-- /result -->

`COUNT(DISTINCT o.order_id)`, not `COUNT(*)`: after the join, the grain is order *lines* (lesson 06).

## 3. Best customers

```sql
SELECT c.customer_id, c.full_name, c.city,
       COUNT(DISTINCT o.order_id) AS paid_orders,
       SUM(i.quantity * i.unit_price_cents) AS revenue_cents
FROM customers c
JOIN orders o      ON o.customer_id = c.customer_id AND o.status = 'paid'
JOIN order_items i ON i.order_id = o.order_id
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY revenue_cents DESC, c.customer_id
LIMIT 3;
```

<!-- result -->
| customer_id | full_name | city | paid_orders | revenue_cents |
|---|---|---|---|---|
| 1 | Ana Ionescu | Bucharest | 2 | 25550 |
| 4 | Darius Ene | Timișoara | 1 | 19600 |
| 8 | Horia Vlad | Oradea | 1 | 16150 |
<!-- /result -->

## 4. Best products by units

```sql
SELECT p.sku, p.product_name, SUM(i.quantity) AS units
FROM order_items i
JOIN orders o   ON o.order_id = i.order_id
JOIN products p ON p.product_id = i.product_id
WHERE o.status = 'paid'
GROUP BY p.product_id, p.sku, p.product_name
ORDER BY units DESC, p.sku
LIMIT 3;
```

<!-- result -->
| sku | product_name | units |
|---|---|---|
| P02 | Pen | 6 |
| P01 | Notebook | 5 |
| P06 | Marker | 4 |
<!-- /result -->

The Pen sold 10 units in order 108, but that order is pending, so those units don't count.

## 5. Anything that looks wrong?

A report you can't check is a guess. Two independent checks:

**(a) The total must match.** Revenue summed by month must equal revenue computed directly:

```sql
SELECT SUM(i.quantity * i.unit_price_cents) AS paid_line_cents
FROM order_items i
JOIN orders o ON o.order_id = i.order_id
WHERE o.status = 'paid';
```

<!-- result -->
| paid_line_cents |
|---|
| 101950 |
<!-- /result -->

Add up the monthly `revenue_cents` from section 2: they give the same 101 950.

**(b) Do payments agree with order lines?** Every paid order should have a payment equal to its line total. The next query lists any disagreement; an empty result is the good outcome:

```sql
SELECT o.order_id,
       SUM(i.quantity * i.unit_price_cents) AS line_cents,
       (SELECT SUM(p.amount_cents) FROM payments p WHERE p.order_id = o.order_id) AS paid_cents
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.order_id
HAVING line_cents <> COALESCE(paid_cents, 0)
ORDER BY o.order_id;
```

<!-- result -->
| order_id | line_cents | paid_cents |
|---|---|---|
| *(no rows)* |  |  |
<!-- /result -->

No mismatches today. The exercises' edge fixture shortens one payment by 100 cents, and this query would catch it. The `(SELECT …)` in the `SELECT` list is a *subquery*, which the Intermediate level covers properly.

## 6. Checklist for any report

- [ ] The grain of every query is stated (one row per …).
- [ ] Status filters match the definitions table.
- [ ] Counts after a join use `COUNT(DISTINCT key)` where needed.
- [ ] Every `ORDER BY … LIMIT` has a tie-breaker.
- [ ] A total is cross-checked by an independent query.
- [ ] Money stays in integer cents until the final display.

## Common mistakes

| Mistake | What happens | Fix |
|---|---|---|
| Counting `COUNT(*)` after joining orders to lines | Order counts equal line counts | `COUNT(DISTINCT o.order_id)` |
| Including pending or cancelled orders in revenue | Revenue too high | Filter by the status in your definitions table |
| Grouping customers by name | Two different people merge | Group by `customer_id`, show the name |
| Formatting euros early, then summing text | Wrong totals or type errors | Sum cents, format last |
| No cross-check | A wrong report goes out | An independent total for every report |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PB20` | **Paid order summary.** For paid orders only, return order_id, line_count (number of order lines) and total_cents (sum of quantity × unit_price_cents), sorted by order_id. | query |
| `PB54` | **Top three paid orders.** Return order_id, full_name, total_cents (sum of quantity × unit_price_cents) for the three paid orders with the highest total, highest first, ties by order_id. | query |
| `PB55` | **Paying customers.** Return one row, paying_customers: the number of different customers with at least one paid order. | query |
| `PB56` | **Revenue by payment month.** Return month (paid_at as YYYY-MM) and received_cents (sum of payments.amount_cents) per month, sorted by month. | query |
| `PB57` | **Best sellers by units.** Return sku, units (total quantity on lines of paid orders) for the three best-selling products, most units first, ties by sku. | query |
| `PB58` | **Revenue by city.** Return city, revenue_cents (paid order lines of customers in that city) for cities with paid revenue, sorted by revenue_cents descending, then city. | query |

```bash
python tools/practice.py show PB20
python tools/practice.py check PB20
python tools/practice.py hint PB20 1
```
<!-- /exercises -->

Then take the [Basics assessment](../ASSESSMENT.md) and run `python tools/verify_level.py basics`.

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** In this course's reports, revenue counts lines of orders with status…

   - **a)** paid only
   - **b)** paid and pending
   - **c)** every status

**2.** After joining orders to order_items, how do you count paid orders per month?

   - **a)** COUNT(*)
   - **b)** COUNT(DISTINCT o.order_id)
   - **c)** SUM(o.order_id)

**3.** Why cross-check the monthly report against a direct total?

   - **a)** To make the query faster
   - **b)** An independent total catches grouping and filtering mistakes
   - **c)** SQLite requires it

```bash
python tools/quiz.py basics/09 1 b      # question 1, answer b
python tools/quiz.py basics/09           # list the questions
```
<!-- /quiz -->

## Summary

- Define business terms (revenue, month, customer) before writing SQL.
- Build reports from joins, filters, groups and sorts you already know.
- Watch the grain after every join.
- Verify with an independent total and a consistency check.

**Next level:** [Intermediate · 00 Multi-table reporting](../../intermediate/lessons/00_multi_table_reports.md)
