-- 00 · Indexes and query plans
-- Examples from advanced/lessons/00_indexes_explain.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/lessons/00_indexes_explain.sql
SELECT name, tbl_name, sql
FROM sqlite_master
WHERE type = 'index'
ORDER BY tbl_name, name;

EXPLAIN QUERY PLAN
SELECT order_id, ordered_at FROM orders WHERE customer_id = 1 ORDER BY ordered_at;

EXPLAIN QUERY PLAN
SELECT customer_id, full_name FROM customers WHERE city = 'Bucharest';

CREATE INDEX idx_customers_city ON customers(city);

EXPLAIN QUERY PLAN
SELECT customer_id, full_name FROM customers WHERE city = 'Bucharest';

EXPLAIN QUERY PLAN
SELECT order_id FROM orders WHERE ordered_at >= '2026-06-01';

CREATE INDEX idx_orders_status_date ON orders(status, ordered_at);

EXPLAIN QUERY PLAN
SELECT order_id, ordered_at FROM orders
WHERE status = 'paid' AND ordered_at >= '2026-04-01'
ORDER BY ordered_at;

EXPLAIN QUERY PLAN
SELECT order_id FROM orders WHERE substr(ordered_at, 1, 7) = '2026-06';

EXPLAIN QUERY PLAN
SELECT order_id FROM orders WHERE status = 'paid' AND ordered_at >= '2026-06-01' AND ordered_at < '2026-07-01';

CREATE INDEX idx_items_product_qty ON order_items(product_id, quantity);

EXPLAIN QUERY PLAN
SELECT product_id, SUM(quantity) FROM order_items GROUP BY product_id;
