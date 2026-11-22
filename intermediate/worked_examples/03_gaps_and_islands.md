# Worked example I3 · Buying streaks (gaps and islands)

**Problem.** Loyalty wants each customer's **streaks**: runs of consecutive months in which they placed an order. Ana ordering in January, February and March is one 3-month streak; a gap starts a new one.

**Run:** `python tools/run_sql.py intermediate/worked_examples/03_gaps_and_islands.sql`

## 1. Plan

This is the classic *gaps and islands* problem. Give Ana a few more orders so there's something to find:

```sql
INSERT INTO orders VALUES
  (120, 1, '2026-02-20', 'paid'),
  (121, 1, '2026-05-03', 'paid'),
  (122, 1, '2026-06-11', 'paid');
```

<!-- result -->
*Rows changed: 3*
<!-- /result -->

Ana now orders in months 1, 2, 3, 5 and 6, so she has two islands: 1–3 and 5–6.

## 2. The trick: month number minus row number

Number each customer's distinct order months in order. Within a streak, the month number and the row number both go up by 1, so their **difference stays constant**. A gap changes it.

```sql
WITH months AS (
  SELECT DISTINCT customer_id,
         CAST(strftime('%Y', ordered_at) AS INTEGER) * 12 + CAST(strftime('%m', ordered_at) AS INTEGER) AS month_no,
         strftime('%Y-%m', ordered_at) AS month
  FROM orders
  WHERE customer_id = 1
)
SELECT customer_id, month, month_no,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY month_no) AS rn,
       month_no - ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY month_no) AS island
FROM months
ORDER BY month_no;
```

<!-- result -->
| customer_id | month | month_no | rn | island |
|---|---|---|---|---|
| 1 | 2026-01 | 24313 | 1 | 24312 |
| 1 | 2026-02 | 24314 | 2 | 24312 |
| 1 | 2026-03 | 24315 | 3 | 24312 |
| 1 | 2026-05 | 24317 | 4 | 24313 |
| 1 | 2026-06 | 24318 | 5 | 24313 |
<!-- /result -->

`month_no = year × 12 + month` makes December → January consecutive (2026-12 is followed by 2027-01).

## 3. Group by the island key

```sql
WITH months AS (
  SELECT DISTINCT customer_id,
         CAST(strftime('%Y', ordered_at) AS INTEGER) * 12 + CAST(strftime('%m', ordered_at) AS INTEGER) AS month_no,
         strftime('%Y-%m', ordered_at) AS month
  FROM orders
), islands AS (
  SELECT customer_id, month, month_no,
         month_no - ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY month_no) AS island
  FROM months
)
SELECT customer_id, MIN(month) AS streak_start, MAX(month) AS streak_end, COUNT(*) AS months
FROM islands
GROUP BY customer_id, island
HAVING COUNT(*) >= 2
ORDER BY customer_id, streak_start;
```

<!-- result -->
| customer_id | streak_start | streak_end | months |
|---|---|---|---|
| 1 | 2026-01 | 2026-03 | 3 |
| 1 | 2026-05 | 2026-06 | 2 |
<!-- /result -->

## 4. Test it

| Case | Expected |
|---|---|
| Two orders in the same month | counted once (`DISTINCT` month) |
| Months 1, 2, 3 | one streak of 3 |
| A one-month gap | two separate streaks |
| December → January | consecutive, thanks to `year × 12 + month` |

The same pattern finds consecutive login days, uninterrupted subscription periods and runs of failed jobs.

**Practise next:** [PI36](../../practice/starter/PI36.sql), [PI12](../../practice/starter/PI12.sql).
