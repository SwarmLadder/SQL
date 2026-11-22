-- 02 · ORDER BY and LIMIT
-- Examples from basics/lessons/02_sort_limit.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/lessons/02_sort_limit.sql
SELECT sku, product_name, unit_price_cents
FROM products
WHERE active = 1
ORDER BY unit_price_cents DESC;

SELECT customer_id, order_id, ordered_at
FROM orders
ORDER BY customer_id, ordered_at DESC;

SELECT sku, unit_price_cents
FROM products
ORDER BY unit_price_cents, sku;

SELECT order_id, ordered_at
FROM orders
ORDER BY ordered_at DESC, order_id DESC
LIMIT 3;

SELECT order_id, ordered_at
FROM orders
ORDER BY ordered_at DESC, order_id DESC
LIMIT 3 OFFSET 3;

SELECT full_name, manager_id
FROM employees
ORDER BY manager_id IS NULL, manager_id, employee_id;
