-- Worked example B4 · Percentages that aren't zero
-- Examples from basics/worked_examples/04_percentages.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/worked_examples/04_percentages.sql
SELECT (SELECT COUNT(*) FROM orders WHERE status = 'paid') * 100
       / (SELECT COUNT(*) FROM orders) AS paid_pct_int,
       (SELECT COUNT(*) FROM orders WHERE status = 'paid')
       / (SELECT COUNT(*) FROM orders) * 100 AS paid_pct_broken;

SELECT COUNT(*) AS orders,
       SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) AS paid,
       ROUND(100.0 * SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) / COUNT(*), 1) AS paid_pct
FROM orders;

SELECT status,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / NULLIF((SELECT COUNT(*) FROM orders WHERE status = 'refunded'), 0), 1) AS pct_of_refunded
FROM orders
GROUP BY status
ORDER BY status;
