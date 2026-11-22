# 06 · LAG, LEAD, and running totals

> **You will learn** to look at the previous and next row with `LAG` and `LEAD`, to compute running totals and moving averages, how a **window frame** (`ROWS BETWEEN …`) decides which rows are included, and the `ROWS` vs `RANGE` difference with duplicate sort values.
> **Time:** about 55 minutes · **Before this:** [05 · Window functions and rankings](05_windows_ranking.md)

Time-ordered questions compare a row with its neighbours: "how long since this customer's previous order?", "how much did revenue change since last month?", "what's our revenue so far this year?". Ordered windows answer all of them.

**Run the whole lesson:** `python tools/run_sql.py intermediate/lessons/06_windows_running.sql`

## 1. LAG and LEAD

`LAG(x)` returns `x` from the **previous** row of the window, `LEAD(x)` from the **next**. The window's `ORDER BY` defines "previous".

```sql
SELECT customer_id, order_id, ordered_at,
       LAG(ordered_at)  OVER w AS previous_order,
       LEAD(ordered_at) OVER w AS next_order,
       CAST(julianday(ordered_at) - julianday(LAG(ordered_at) OVER w) AS INTEGER) AS days_since_previous
FROM orders
WINDOW w AS (PARTITION BY customer_id ORDER BY ordered_at, order_id)
ORDER BY customer_id, ordered_at;
```

<!-- result -->
| customer_id | order_id | ordered_at | previous_order | next_order | days_since_previous |
|---|---|---|---|---|---|
| 1 | 101 | 2026-01-12 | *NULL* | 2026-03-02 | *NULL* |
| 1 | 103 | 2026-03-02 | 2026-01-12 | *NULL* | 49 |
| 2 | 102 | 2026-02-05 | *NULL* | 2026-05-14 | *NULL* |
| 2 | 108 | 2026-05-14 | 2026-02-05 | *NULL* | 98 |
| 3 | 104 | 2026-03-12 | *NULL* | 2026-07-08 | *NULL* |
| 3 | 111 | 2026-07-08 | 2026-03-12 | *NULL* | 118 |
| 4 | 105 | 2026-04-06 | *NULL* | *NULL* | *NULL* |
| 5 | 106 | 2026-04-15 | *NULL* | *NULL* | *NULL* |
| 6 | 107 | 2026-05-04 | *NULL* | *NULL* | *NULL* |
| 7 | 109 | 2026-06-02 | *NULL* | *NULL* | *NULL* |
| 8 | 110 | 2026-06-21 | *NULL* | *NULL* | *NULL* |
<!-- /result -->

- The first row of each partition has no previous row, so `LAG` returns `NULL` (and the day difference is `NULL` too).
- `LAG(x, 2)` looks two rows back; `LAG(x, 1, 0)` returns `0` instead of `NULL` when there's no previous row.

## 2. Period-over-period change

Aggregate to one row per month first, then compare each month with the previous one:

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
       LAG(revenue_cents) OVER (ORDER BY month) AS previous_cents,
       revenue_cents - LAG(revenue_cents) OVER (ORDER BY month) AS change_cents,
       ROUND(100.0 * (revenue_cents - LAG(revenue_cents) OVER (ORDER BY month))
             / LAG(revenue_cents) OVER (ORDER BY month), 1) AS change_pct
FROM monthly
ORDER BY month;
```

<!-- result -->
| month | revenue_cents | previous_cents | change_cents | change_pct |
|---|---|---|---|---|
| 2026-01 | 3150 | *NULL* | *NULL* | *NULL* |
| 2026-02 | 5400 | 3150 | 2250 | 71.4 |
| 2026-03 | 22400 | 5400 | 17000 | 314.8 |
| 2026-04 | 19600 | 22400 | -2800 | -12.5 |
| 2026-05 | 10100 | 19600 | -9500 | -48.5 |
| 2026-06 | 27500 | 10100 | 17400 | 172.3 |
| 2026-07 | 13800 | 27500 | -13700 | -49.8 |
<!-- /result -->

`LAG` compares with the previous **row**, not the previous **calendar month**. If a month had no sales, it would be missing, and `LAG` would silently compare with two months ago. Real dashboards generate a complete calendar first (the Advanced level shows how with a recursive CTE).

## 3. Running totals

`SUM(x) OVER (ORDER BY …)` adds up everything from the first row to the current one:

```sql
SELECT paid_at, payment_id, amount_cents,
       SUM(amount_cents) OVER (ORDER BY paid_at, payment_id) AS running_cents,
       COUNT(*)          OVER (ORDER BY paid_at, payment_id) AS payments_so_far
FROM payments
ORDER BY paid_at, payment_id;
```

<!-- result -->
| paid_at | payment_id | amount_cents | running_cents | payments_so_far |
|---|---|---|---|---|
| 2026-01-12 | 1 | 3150 | 3150 | 1 |
| 2026-02-05 | 2 | 5400 | 8550 | 2 |
| 2026-03-02 | 3 | 22400 | 30950 | 3 |
| 2026-04-06 | 4 | 19600 | 50550 | 4 |
| 2026-05-04 | 5 | 10100 | 60650 | 5 |
| 2026-06-02 | 6 | 11350 | 72000 | 6 |
| 2026-06-21 | 7 | 16150 | 88150 | 7 |
| 2026-07-08 | 8 | 13800 | 101950 | 8 |
<!-- /result -->

Add `PARTITION BY` to restart the total per group, for example per customer or per year.

## 4. Window frames: which rows count?

With an `ORDER BY` in the window, aggregates use a **frame**: by default *all rows from the start up to the current row*. You can set the frame explicitly:

```sql
WITH monthly AS (
  SELECT SUBSTR(paid_at, 1, 7) AS month, SUM(amount_cents) AS revenue_cents
  FROM payments GROUP BY month
)
SELECT month, revenue_cents,
       ROUND(AVG(revenue_cents) OVER (ORDER BY month
                                      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)) AS moving_avg_3,
       SUM(revenue_cents) OVER (ORDER BY month
                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS grand_total
FROM monthly
ORDER BY month;
```

<!-- result -->
| month | revenue_cents | moving_avg_3 | grand_total |
|---|---|---|---|
| 2026-01 | 3150 | 3150.0 | 101950 |
| 2026-02 | 5400 | 4275.0 | 101950 |
| 2026-03 | 22400 | 10317.0 | 101950 |
| 2026-04 | 19600 | 15800.0 | 101950 |
| 2026-05 | 10100 | 17367.0 | 101950 |
| 2026-06 | 27500 | 19067.0 | 101950 |
| 2026-07 | 13800 | 17133.0 | 101950 |
<!-- /result -->

| Frame | Rows included |
|---|---|
| `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` | start → current row (running total) |
| `ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` | the current and two previous rows (moving window) |
| `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` | the whole partition |

## 5. ROWS vs RANGE: the duplicate trap

The **default** frame is `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. `RANGE` treats rows with the **same** `ORDER BY` value as one step, so they all get the same running total. Two payments share the date 2026-06-21 if we add one:

```sql
BEGIN;
INSERT INTO payments VALUES (91, 109, 50, 'cash', '2026-06-21');

SELECT paid_at, payment_id, amount_cents,
       SUM(amount_cents) OVER (ORDER BY paid_at) AS range_default,
       SUM(amount_cents) OVER (ORDER BY paid_at ROWS UNBOUNDED PRECEDING) AS rows_frame
FROM payments
WHERE paid_at >= '2026-06-01'
ORDER BY paid_at, payment_id;

ROLLBACK;
```

<!-- result -->
*Rows changed: 1*

| paid_at | payment_id | amount_cents | range_default | rows_frame |
|---|---|---|---|---|
| 2026-06-02 | 6 | 11350 | 11350 | 11350 |
| 2026-06-21 | 7 | 16150 | 27550 | 27500 |
| 2026-06-21 | 91 | 50 | 27550 | 27550 |
| 2026-07-08 | 8 | 13800 | 41350 | 41350 |
<!-- /result -->

With `RANGE` both 2026-06-21 rows show the total *including each other*; with `ROWS` they step one at a time, but in an order the database chooses unless you add a tie-breaker. **Best practice:** make the window's `ORDER BY` unique (`ORDER BY paid_at, payment_id`), and then `ROWS` and `RANGE` agree.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| `LAG` over monthly rows with gaps | Compares with the wrong month | Build a complete calendar first |
| Non-unique window `ORDER BY` | Running totals jump or repeat | Add a tie-breaker |
| Expecting the default frame to be `ROWS` | Tied rows share a total | Write the frame explicitly |
| Dividing by `LAG(…)` when it is NULL or 0 | NULL or division error | Guard with `NULLIF(LAG(…), 0)` |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PI12` | **Previous order date.** Return customer_id, order_id, ordered_at, previous_ordered_at (the same customer's previous order date, NULL for their first order). Sort by customer_id, ordered_at, order_id. | query |
| `PI13` | **Running revenue by month.** Group payments by month of paid_at (format YYYY-MM). Return month, revenue_cents and running_cents (cumulative revenue up to and including that month). Sort by month. | query |
| `PI20` | **Monthly revenue dashboard.** Using order lines of paid orders, group by month of ordered_at (YYYY-MM). Return month, revenue_cents and change_cents (this month minus the previous month; NULL for the first month). Sort by month. | query |
| `PI36` | **Days since the previous order.** Return customer_id, order_id, days_since_previous (whole days since the same customer's previous order; NULL for their first) for every order. Sort by customer_id, ordered_at, order_id. | query |
| `PI37` | **Running spend per customer.** For paid orders, return customer_id, order_id, total_cents (the order's line total) and running_cents (the customer's cumulative paid total up to and including this order, by ordered_at then order_id). Sort by customer_id, ordered_at, order_id. | query |
| `PI38` | **Three-month moving average.** Group payments by month of paid_at (YYYY-MM). Return month and moving_avg_3: the average of this month's and up to two previous months' received amounts, rounded to a whole number. Sort by month. | query |

```bash
python tools/practice.py show PI12
python tools/practice.py check PI12
python tools/practice.py hint PI12 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** What does LAG return on the first row of a partition?

   - **a)** 0
   - **b)** The same row's value
   - **c)** NULL, unless you give a default

**2.** Monthly rows skip a month with no sales. What does LAG(revenue) compare with?

   - **a)** The previous calendar month, as 0
   - **b)** The previous row, i.e. two months back
   - **c)** Nothing, it errors

**3.** Which frame gives a three-row moving average?

   - **a)** ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
   - **b)** ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
   - **c)** RANGE UNBOUNDED PRECEDING

**4.** Two rows share the same ORDER BY value. With the default frame, their running totals are…

   - **a)** different, one step at a time
   - **b)** equal, because RANGE treats ties as one step
   - **c)** NULL

```bash
python tools/quiz.py intermediate/06 1 b      # question 1, answer b
python tools/quiz.py intermediate/06           # list the questions
```
<!-- /quiz -->

## Summary

- `LAG`/`LEAD` read the previous/next row in the window order; the first/last row gets NULL.
- `SUM(x) OVER (ORDER BY …)` is a running total; `PARTITION BY` restarts it.
- Frames (`ROWS BETWEEN …`) choose which rows an aggregate sees; moving averages use a bounded frame.
- The default frame is `RANGE`, which groups ties. Make the order unique or use `ROWS`.

**Next:** [07 · Text, dates, and grouped timelines](07_dates_strings.md)
