CREATE TABLE category_sales_summary AS
SELECT p.category_id,SUM(oi.quantity*oi.unit_price_cents) AS total_cents
FROM order_items oi JOIN products p ON p.product_id=oi.product_id
JOIN orders o ON o.order_id=oi.order_id
WHERE o.status='paid' GROUP BY p.category_id;
SELECT * FROM category_sales_summary ORDER BY category_id;
-- Source changes; summary does not refresh automatically.
INSERT INTO orders(order_id,customer_id,ordered_at,status)
VALUES (200,1,'2026-11-20','paid');
INSERT INTO order_items(order_id,product_id,quantity,unit_price_cents)
VALUES (200,1,1,1200);
SELECT SUM(total_cents) AS snapshot_total FROM category_sales_summary;
SELECT SUM(oi.quantity*oi.unit_price_cents) AS source_total
FROM order_items oi JOIN orders o ON o.order_id=oi.order_id WHERE o.status='paid';
