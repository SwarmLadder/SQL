-- 09 · Views, savepoints, and transactions
-- Examples from intermediate/lessons/09_views_savepoints.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/lessons/09_views_savepoints.sql
CREATE VIEW paid_order_totals AS
SELECT o.order_id, o.customer_id, o.ordered_at,
       SUM(i.quantity * i.unit_price_cents) AS total_cents
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.order_id, o.customer_id, o.ordered_at;

SELECT customer_id, COUNT(*) AS paid_orders, SUM(total_cents) AS revenue_cents
FROM paid_order_totals
GROUP BY customer_id
ORDER BY revenue_cents DESC, customer_id
LIMIT 3;

BEGIN;
INSERT INTO orders VALUES (200, 5, '2026-08-01', 'paid');
INSERT INTO order_items VALUES (200, 4, 1, 15900);

SELECT order_id, total_cents FROM paid_order_totals WHERE order_id = 200;

ROLLBACK;

SELECT COUNT(*) AS rows_for_200 FROM paid_order_totals WHERE order_id = 200;

BEGIN;
INSERT INTO orders VALUES (201, 6, '2026-08-02', 'pending');
INSERT INTO order_items VALUES (201, 1, 1, 1200);
UPDATE orders SET status = 'paid' WHERE order_id = 201;
INSERT INTO payments VALUES (95, 201, 1200, 'card', '2026-08-02');
COMMIT;

SELECT o.order_id, o.status, p.amount_cents
FROM orders o JOIN payments p ON p.order_id = o.order_id
WHERE o.order_id = 201;

BEGIN;
UPDATE products SET unit_price_cents = 1300 WHERE product_id = 1;

SAVEPOINT risky_change;
UPDATE products SET unit_price_cents = 0 WHERE category_id = 2;
SELECT COUNT(*) AS free_products FROM products WHERE unit_price_cents = 0;
ROLLBACK TO risky_change;
RELEASE risky_change;

COMMIT;

SELECT product_id, unit_price_cents FROM products WHERE product_id IN (1, 2, 6) ORDER BY product_id;
