-- 08 · INSERT, UPDATE, DELETE
-- Examples from basics/lessons/08_dml.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/lessons/08_dml.sql
INSERT INTO products (product_id, sku, category_id, product_name, unit_price_cents, active)
VALUES (20, 'P20', 2, 'Stapler', 1800, 1);

SELECT product_id, sku, product_name, unit_price_cents
FROM products
WHERE product_id = 20;

CREATE TABLE cancelled_orders (order_id INTEGER PRIMARY KEY, customer_id INTEGER, ordered_at TEXT);

INSERT INTO cancelled_orders (order_id, customer_id, ordered_at)
SELECT order_id, customer_id, ordered_at
FROM orders
WHERE status = 'cancelled';

SELECT * FROM cancelled_orders;

SELECT product_id, sku, unit_price_cents
FROM products
WHERE category_id = 2 AND active = 1;

UPDATE products
SET unit_price_cents = unit_price_cents * 110 / 100
WHERE category_id = 2 AND active = 1;

SELECT product_id, sku, unit_price_cents
FROM products
WHERE category_id = 2 AND active = 1;

DELETE FROM order_items WHERE order_id = 106;
DELETE FROM orders WHERE order_id = 106;
SELECT COUNT(*) AS orders_left FROM orders;

BEGIN;
UPDATE orders SET status = 'cancelled' WHERE status = 'pending';
SELECT status, COUNT(*) AS orders FROM orders GROUP BY status ORDER BY status;
ROLLBACK;

SELECT status, COUNT(*) AS orders FROM orders GROUP BY status ORDER BY status;
