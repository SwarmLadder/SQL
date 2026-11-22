-- 02 · EXISTS and correlated subqueries
-- Examples from intermediate/lessons/02_exists.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/lessons/02_exists.sql
SELECT c.customer_id, c.full_name
FROM customers c
WHERE EXISTS (SELECT 1
              FROM orders o
              WHERE o.customer_id = c.customer_id
                AND o.status = 'pending')
ORDER BY c.customer_id;

SELECT p.sku, p.product_name
FROM products p
WHERE NOT EXISTS (SELECT 1
                  FROM order_items i
                  JOIN orders o ON o.order_id = i.order_id
                  WHERE i.product_id = p.product_id
                    AND o.status = 'paid')
ORDER BY p.sku;

BEGIN;
INSERT INTO products VALUES (30, 'P30', 1, 'Unsold Atlas', 3000, 1);
INSERT INTO order_items VALUES (106, 30, 1, 3000);

SELECT p.sku, p.product_name
FROM products p
WHERE NOT EXISTS (SELECT 1
                  FROM order_items i
                  JOIN orders o ON o.order_id = i.order_id
                  WHERE i.product_id = p.product_id
                    AND o.status = 'paid')
ORDER BY p.sku;

ROLLBACK;

SELECT e.full_name
FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM employees r WHERE r.manager_id = e.employee_id)
ORDER BY e.employee_id;

SELECT c.full_name, c.joined_at
FROM customers c
WHERE EXISTS (SELECT 1
              FROM orders o
              WHERE o.customer_id = c.customer_id
                AND julianday(o.ordered_at) - julianday(c.joined_at) <= 30)
ORDER BY c.customer_id;
