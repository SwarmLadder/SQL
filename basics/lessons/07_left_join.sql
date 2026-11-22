-- 07 · LEFT JOIN and missing data
-- Examples from basics/lessons/07_left_join.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/lessons/07_left_join.sql
SELECT e.full_name AS employee, m.full_name AS manager
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id
ORDER BY e.employee_id;

BEGIN;
INSERT INTO products VALUES (20, 'P20', 4, 'Plant Pot', 1900, 1);

SELECT p.sku, p.product_name
FROM products p
LEFT JOIN order_items i ON i.product_id = p.product_id
WHERE i.product_id IS NULL;

ROLLBACK;

BEGIN;
INSERT INTO customers VALUES (20, 'Ioana Nou', 'ioana@example.test', 'Arad', '2026-08-01');

SELECT c.customer_id, c.full_name,
       COUNT(o.order_id) AS orders,
       COUNT(*)          AS rows_in_group
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY c.customer_id;

ROLLBACK;

SELECT c.full_name, COUNT(o.order_id) AS paid_orders
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.status = 'paid'
GROUP BY c.customer_id, c.full_name
ORDER BY c.customer_id;

SELECT c.full_name, COUNT(o.order_id) AS paid_orders
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'paid'
GROUP BY c.customer_id, c.full_name
ORDER BY c.customer_id;
