-- 00 · SELECT and columns
-- Examples from basics/lessons/00_select.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/lessons/00_select.sql
SELECT name
FROM sqlite_master
WHERE type = 'table'
ORDER BY name;

SELECT full_name, city
FROM customers;

SELECT sku AS product_code,
       product_name AS name,
       unit_price_cents AS price_cents
FROM products;

SELECT DISTINCT status
FROM orders;

SELECT DISTINCT category_id, active
FROM products
ORDER BY category_id, active;

SELECT *
FROM categories;
