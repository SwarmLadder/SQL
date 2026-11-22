-- Worked example I3 · Buying streaks (gaps and islands)
-- Examples from intermediate/worked_examples/03_gaps_and_islands.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/worked_examples/03_gaps_and_islands.sql
INSERT INTO orders VALUES
  (120, 1, '2026-02-20', 'paid'),
  (121, 1, '2026-05-03', 'paid'),
  (122, 1, '2026-06-11', 'paid');

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
