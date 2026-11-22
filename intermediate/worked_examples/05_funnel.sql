-- Worked example I5 · An order funnel by month
-- Examples from intermediate/worked_examples/05_funnel.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/worked_examples/05_funnel.sql
SELECT strftime('%Y-%m', ordered_at) AS month, COUNT(*) AS paid
FROM orders WHERE status = 'paid'
GROUP BY month ORDER BY month;

SELECT strftime('%Y-%m', ordered_at) AS month,
       COUNT(*) AS placed,
       SUM(CASE WHEN status = 'paid'      THEN 1 ELSE 0 END) AS paid,
       SUM(CASE WHEN status = 'pending'   THEN 1 ELSE 0 END) AS pending,
       SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled,
       ROUND(100.0 * SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) / COUNT(*), 1) AS conversion_pct
FROM orders
GROUP BY month
ORDER BY month;

WITH funnel AS (
  SELECT strftime('%Y-%m', ordered_at) AS month,
         COUNT(*) AS placed,
         SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) AS paid
  FROM orders
  GROUP BY month
)
SELECT month, placed, paid,
       SUM(paid)   OVER (ORDER BY month) AS paid_to_date,
       SUM(placed) OVER (ORDER BY month) AS placed_to_date,
       ROUND(100.0 * SUM(paid) OVER (ORDER BY month) / SUM(placed) OVER (ORDER BY month), 1) AS cumulative_conversion_pct
FROM funnel
ORDER BY month;
