-- 01 · Query rewrites and correct grain
-- Examples from advanced/lessons/01_query_rewrites.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/lessons/01_query_rewrites.sql
SELECT c.customer_id,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) AS order_count,
       (SELECT MAX(ordered_at) FROM orders o WHERE o.customer_id = c.customer_id) AS last_order
FROM customers c
ORDER BY c.customer_id;

WITH stats AS (
  SELECT customer_id, COUNT(*) AS order_count, MAX(ordered_at) AS last_order
  FROM orders
  GROUP BY customer_id
)
SELECT c.customer_id, COALESCE(s.order_count, 0) AS order_count, s.last_order
FROM customers c
LEFT JOIN stats s ON s.customer_id = c.customer_id
ORDER BY c.customer_id;

WITH a AS (
  SELECT c.customer_id,
         (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) AS order_count,
         (SELECT MAX(ordered_at) FROM orders o WHERE o.customer_id = c.customer_id) AS last_order
  FROM customers c
), b AS (
  SELECT c.customer_id, COALESCE(s.order_count, 0) AS order_count, s.last_order
  FROM customers c
  LEFT JOIN (SELECT customer_id, COUNT(*) AS order_count, MAX(ordered_at) AS last_order
             FROM orders GROUP BY customer_id) s ON s.customer_id = c.customer_id
)
SELECT (SELECT COUNT(*) FROM (SELECT * FROM a EXCEPT SELECT * FROM b)) AS only_in_a,
       (SELECT COUNT(*) FROM (SELECT * FROM b EXCEPT SELECT * FROM a)) AS only_in_b,
       (SELECT COUNT(*) FROM a) AS rows_a,
       (SELECT COUNT(*) FROM b) AS rows_b;

SELECT (SELECT COUNT(*) FROM customers c
        WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.status = 'paid')) AS exists_rows,
       (SELECT COUNT(*) FROM customers c
        JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'paid') AS join_rows,
       (SELECT COUNT(DISTINCT c.customer_id) FROM customers c
        JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'paid') AS join_distinct_rows;

SELECT order_id FROM orders WHERE customer_id = 2 OR status = 'cancelled'
ORDER BY order_id;

SELECT order_id FROM orders WHERE customer_id = 2
UNION ALL
SELECT order_id FROM orders WHERE status = 'cancelled' AND customer_id <> 2
ORDER BY order_id;

SELECT order_id, ordered_at FROM orders
ORDER BY ordered_at, order_id
LIMIT 4;

SELECT order_id, ordered_at FROM orders
WHERE (ordered_at, order_id) > ('2026-03-12', 104)
ORDER BY ordered_at, order_id
LIMIT 4;
