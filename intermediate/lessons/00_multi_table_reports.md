# 00 · Multi-table reporting

> **You will learn** to plan a report before writing it, to recognise **fan-out** (rows multiplied by joining two one-to-many tables), to fix it by aggregating each table to the report's grain before joining, and to verify totals.
> **Time:** about 50 minutes · **Before this:** the whole [Basics level](../../basics/README.md), especially [06 · INNER JOIN](../../basics/lessons/06_joins.md) and [09 · review](../../basics/lessons/09_review.md)

In Basics every report joined along a single chain. Real reports combine **several independent facts** about the same entity, such as what an order contained *and* what was paid for it. Done naively, this is the most common source of inflated numbers in business reporting.

**Run the whole lesson:** `python tools/run_sql.py intermediate/lessons/00_multi_table_reports.sql`

## 1. Plan the report first

Question: *for each paid order, what was ordered and what was paid?*

| Decision | Answer |
|---|---|
| Grain | one row per paid order |
| Facts | item total (from `order_items`), payment total (from `payments`) |
| Relationship | one order → many lines; one order → many payments (here usually one) |
| Missing data | an order without payments must still appear, with 0 |

Two "many" tables hang off the same "one" table. That shape is the warning sign.

## 2. Fan-out: watching the numbers inflate

Join both detail tables at once and sum:

```sql
SELECT o.order_id,
       COUNT(*) AS joined_rows,
       SUM(i.quantity * i.unit_price_cents) AS items_cents,
       SUM(p.amount_cents) AS paid_cents
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
LEFT JOIN payments p ON p.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.order_id
ORDER BY o.order_id;
```

<!-- result -->
| order_id | joined_rows | items_cents | paid_cents |
|---|---|---|---|
| 101 | 2 | 3150 | 6300 |
| 102 | 2 | 5400 | 10800 |
| 103 | 2 | 22400 | 44800 |
| 105 | 2 | 19600 | 39200 |
| 107 | 2 | 10100 | 20200 |
| 109 | 2 | 11350 | 22700 |
| 110 | 2 | 16150 | 32300 |
| 111 | 2 | 13800 | 27600 |
<!-- /result -->

Order 101 was paid 3 150 cents once, yet `paid_cents` shows 6 300. The join produced one row per *line × payment*: two lines times one payment gives two rows, and the payment amount is repeated on both. Each extra line multiplies the payment again. With two payments, the items would double too.

Make it visible with a second payment (inside a transaction):

```sql
BEGIN;
INSERT INTO payments VALUES (90, 101, 1, 'cash', '2026-01-13');

SELECT o.order_id, i.product_id, p.payment_id, p.amount_cents
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
LEFT JOIN payments p ON p.order_id = o.order_id
WHERE o.order_id = 101
ORDER BY i.product_id, p.payment_id;

ROLLBACK;
```

<!-- result -->
*Rows changed: 1*

| order_id | product_id | payment_id | amount_cents |
|---|---|---|---|
| 101 | 1 | 1 | 3150 |
| 101 | 1 | 90 | 1 |
| 101 | 2 | 1 | 3150 |
| 101 | 2 | 90 | 1 |
<!-- /result -->

2 lines × 2 payments = 4 rows. Each line now appears twice and each payment twice.

**Spot fan-out with this test:** after a join, does `COUNT(*)` per group equal the number of rows in *either* detail table? If it equals the product of both, you have fan-out.

## 3. The fix: aggregate each fact to the grain, then join

Reduce each detail table to **one row per order first**, then join the summaries. Each summary is one-to-one with the order, so nothing multiplies.

```sql
SELECT o.order_id,
       items.items_cents,
       COALESCE(paid.paid_cents, 0) AS paid_cents
FROM orders o
JOIN (SELECT order_id, SUM(quantity * unit_price_cents) AS items_cents
      FROM order_items GROUP BY order_id) AS items
  ON items.order_id = o.order_id
LEFT JOIN (SELECT order_id, SUM(amount_cents) AS paid_cents
           FROM payments GROUP BY order_id) AS paid
  ON paid.order_id = o.order_id
WHERE o.status = 'paid'
ORDER BY o.order_id;
```

<!-- result -->
| order_id | items_cents | paid_cents |
|---|---|---|
| 101 | 3150 | 3150 |
| 102 | 5400 | 5400 |
| 103 | 22400 | 22400 |
| 105 | 19600 | 19600 |
| 107 | 10100 | 10100 |
| 109 | 11350 | 11350 |
| 110 | 16150 | 16150 |
| 111 | 13800 | 13800 |
<!-- /result -->

The subqueries in `FROM` are **derived tables**: a query used as if it were a table, given an alias with `AS`. Lesson 03 rewrites them as CTEs, which read better.

## 4. Report at the customer grain

The same rule holds at any grain. Per customer: number of paid orders, item value, payments received:

```sql
SELECT c.customer_id, c.full_name,
       COALESCE(ord.paid_orders, 0)  AS paid_orders,
       COALESCE(ord.items_cents, 0)  AS items_cents,
       COALESCE(pay.received_cents, 0) AS received_cents
FROM customers c
LEFT JOIN (
  SELECT o.customer_id, COUNT(DISTINCT o.order_id) AS paid_orders,
         SUM(i.quantity * i.unit_price_cents) AS items_cents
  FROM orders o JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.customer_id
) AS ord ON ord.customer_id = c.customer_id
LEFT JOIN (
  SELECT o.customer_id, SUM(p.amount_cents) AS received_cents
  FROM payments p JOIN orders o ON o.order_id = p.order_id
  GROUP BY o.customer_id
) AS pay ON pay.customer_id = c.customer_id
ORDER BY items_cents DESC, c.customer_id;
```

<!-- result -->
| customer_id | full_name | paid_orders | items_cents | received_cents |
|---|---|---|---|---|
| 1 | Ana Ionescu | 2 | 25550 | 25550 |
| 4 | Darius Ene | 1 | 19600 | 19600 |
| 8 | Horia Vlad | 1 | 16150 | 16150 |
| 3 | Carmen Radu | 1 | 13800 | 13800 |
| 7 | Gabriela Dinu | 1 | 11350 | 11350 |
| 6 | Florin Matei | 1 | 10100 | 10100 |
| 2 | Bogdan Pop | 1 | 5400 | 5400 |
| 5 | Elena Stan | 0 | 0 | 0 |
<!-- /result -->

Elena (5) appears with zeros because her only order was cancelled. Starting from `customers` and left-joining the summaries keeps everyone.

## 5. Verify: totals must survive the reshaping

A correct report preserves the grand totals of its sources. Compare the report's total with the source total:

```sql
SELECT (SELECT SUM(amount_cents) FROM payments) AS source_payments,
       (SELECT SUM(paid_cents)
        FROM (SELECT order_id, SUM(amount_cents) AS paid_cents
              FROM payments GROUP BY order_id)) AS report_payments;
```

<!-- result -->
| source_payments | report_payments |
|---|---|
| 101950 | 101950 |
<!-- /result -->

If the fanned-out query from section 2 were checked this way, its `paid_cents` would add up to far more than the real payments total.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Joining two one-to-many tables, then summing | Totals 2×, 3×… too high on some rows | Aggregate each table to the grain first |
| "Fixing" fan-out with `SUM(DISTINCT amount)` | Breaks when two real payments have the same amount | Pre-aggregate; never de-duplicate values |
| Inner-joining a summary that can be missing | Entities without that fact disappear | `LEFT JOIN` + `COALESCE(…, 0)` |
| No grand-total check | Inflation goes unnoticed | Compare report totals with source totals |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PI02` | **Items vs payments without fan-out.** For paid orders, return order_id, items_cents (sum of quantity × unit_price_cents) and paid_cents (sum of payment amounts, 0 if none), sorted by order_id. Joining items and payments directly multiplies rows; aggregate each side first. | query |
| `PI21` | **Lines and payments per order.** For paid orders, return order_id, line_count (number of order lines) and payment_count (number of payments, 0 if none), sorted by order_id. Count each table separately so neither count is multiplied by the other. | query |
| `PI22` | **Paid orders that don't add up.** Return order_id, items_cents, paid_cents (0 if no payment) for paid orders whose payment total differs from their item total, sorted by order_id. (The course data has none; the edge fixture has one.) | query |

```bash
python tools/practice.py show PI02
python tools/practice.py check PI02
python tools/practice.py hint PI02 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** An order has 3 lines and 2 payments. Joining orders, order_items and payments gives how many rows for it?

   - **a)** 5
   - **b)** 6
   - **c)** 3

**2.** What is the reliable fix for fan-out?

   - **a)** SUM(DISTINCT amount_cents)
   - **b)** Aggregate each detail table to the report grain, then join
   - **c)** Use LEFT JOIN instead of JOIN

**3.** A customer has no paid orders. How do you keep them in a per-customer report?

   - **a)** Start from customers and LEFT JOIN the summaries, with COALESCE
   - **b)** Inner-join the summaries
   - **c)** Filter WHERE revenue IS NOT NULL

**4.** How can you detect inflated totals?

   - **a)** Compare the report's grand total with the source table's total
   - **b)** Check the query runs without errors
   - **c)** Look at the first row

```bash
python tools/quiz.py intermediate/00 1 b      # question 1, answer b
python tools/quiz.py intermediate/00           # list the questions
```
<!-- /quiz -->

## Summary

- Write down the grain and the facts before joining.
- Two "many" tables joined to the same "one" table multiply each other: **fan-out**.
- Aggregate each detail table to the report grain, then join the summaries.
- Start from the entity table and `LEFT JOIN` summaries to keep entities with no facts.
- Check that report totals equal source totals.

**Next:** [01 · Subqueries](01_subqueries.md)
