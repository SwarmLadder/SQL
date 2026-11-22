-- 05 · GROUP BY and HAVING
-- Examples from basics/lessons/05_group_by_having.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/lessons/05_group_by_having.sql
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status
ORDER BY status;

SELECT customer_id,
       COUNT(*)        AS orders,
       MIN(ordered_at) AS first_order,
       MAX(ordered_at) AS last_order
FROM orders
GROUP BY customer_id
ORDER BY customer_id;

SELECT customer_id, status, COUNT(*) AS orders
FROM orders
WHERE customer_id IN (1, 2, 3)
GROUP BY customer_id, status
ORDER BY customer_id, status;

SELECT SUBSTR(ordered_at, 1, 7) AS month,
       COUNT(*) AS orders
FROM orders
GROUP BY month
ORDER BY month;

SELECT customer_id, COUNT(*) AS paid_orders
FROM orders
WHERE status = 'paid'
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY customer_id;
