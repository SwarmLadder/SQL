-- 01 · WHERE, comparisons, and NULL
-- Examples from basics/lessons/01_where_null.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/lessons/01_where_null.sql
SELECT order_id, status
FROM orders
WHERE status = 'pending';

SELECT sku, product_name, unit_price_cents
FROM products
WHERE unit_price_cents >= 6000;

SELECT sku, unit_price_cents, active
FROM products
WHERE active = 1 AND unit_price_cents < 1000;

SELECT order_id, customer_id, status
FROM orders
WHERE status = 'paid' AND customer_id = 1 OR customer_id = 2;

SELECT order_id, customer_id, status
FROM orders
WHERE status = 'paid' AND (customer_id = 1 OR customer_id = 2);

SELECT sku, product_name, unit_price_cents
FROM products
WHERE unit_price_cents BETWEEN 1000 AND 6000
  AND product_name LIKE '%Handbook%';

SELECT employee_id, full_name
FROM employees
WHERE manager_id = NULL;

SELECT employee_id, full_name, manager_id
FROM employees
WHERE manager_id IS NULL;

SELECT full_name, manager_id
FROM employees
WHERE manager_id <> 1
ORDER BY employee_id;
