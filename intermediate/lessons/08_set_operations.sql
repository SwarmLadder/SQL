-- 08 · UNION, INTERSECT, EXCEPT
-- Examples from intermediate/lessons/08_set_operations.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/lessons/08_set_operations.sql
SELECT customer_id FROM orders WHERE status = 'pending'
UNION ALL
SELECT customer_id FROM orders WHERE status = 'paid' AND customer_id <= 3
ORDER BY customer_id;

SELECT customer_id FROM orders WHERE status = 'pending'
UNION
SELECT customer_id FROM orders WHERE status = 'paid' AND customer_id <= 3
ORDER BY customer_id;

SELECT ordered_at AS happened_at, 'order'   AS event, order_id AS ref, NULL AS amount_cents
FROM orders WHERE customer_id = 1
UNION ALL
SELECT paid_at, 'payment', order_id, amount_cents
FROM payments WHERE order_id IN (SELECT order_id FROM orders WHERE customer_id = 1)
ORDER BY happened_at, event;

SELECT i.product_id FROM order_items i JOIN orders o ON o.order_id = i.order_id WHERE o.status = 'pending'
INTERSECT
SELECT i.product_id FROM order_items i JOIN orders o ON o.order_id = i.order_id WHERE o.status = 'paid'
ORDER BY product_id;

SELECT team_id FROM employees
EXCEPT
SELECT team_id FROM employees WHERE manager_id IS NULL
ORDER BY team_id;

BEGIN;
INSERT INTO teams VALUES (4, 'Research');
UPDATE employees SET team_id = 4 WHERE employee_id = 2;

SELECT team_id FROM employees
EXCEPT
SELECT team_id FROM employees WHERE manager_id IS NULL
ORDER BY team_id;

ROLLBACK;

WITH old_version AS (
  SELECT customer_id FROM orders WHERE status = 'paid' GROUP BY customer_id
), new_version AS (
  SELECT c.customer_id FROM customers c
  WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.status = 'paid')
)
SELECT 'only in old' AS side, customer_id FROM (SELECT * FROM old_version EXCEPT SELECT * FROM new_version)
UNION ALL
SELECT 'only in new', customer_id FROM (SELECT * FROM new_version EXCEPT SELECT * FROM old_version);
