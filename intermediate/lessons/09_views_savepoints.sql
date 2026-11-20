CREATE VIEW paid_order_totals AS
SELECT o.order_id, o.customer_id, SUM(oi.quantity*oi.unit_price_cents) AS total_cents
FROM orders o JOIN order_items oi ON oi.order_id=o.order_id
WHERE o.status='paid' GROUP BY o.order_id, o.customer_id;
SELECT * FROM paid_order_totals ORDER BY total_cents DESC LIMIT 5;
SAVEPOINT practice_update;
UPDATE products SET unit_price_cents = unit_price_cents + 100 WHERE product_id=1;
SELECT unit_price_cents FROM products WHERE product_id=1;
ROLLBACK TO practice_update;
RELEASE practice_update;
SELECT unit_price_cents FROM products WHERE product_id=1;
