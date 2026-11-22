-- 09 · Basics review: order report
-- Examples from basics/lessons/09_review.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/lessons/09_review.sql
SELECT SUBSTR(o.ordered_at, 1, 7) AS month,
       COUNT(DISTINCT o.order_id) AS paid_orders,
       SUM(i.quantity * i.unit_price_cents) AS revenue_cents,
       printf('%.2f', SUM(i.quantity * i.unit_price_cents) / 100.0) AS revenue_eur
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY month
ORDER BY month;

SELECT c.customer_id, c.full_name, c.city,
       COUNT(DISTINCT o.order_id) AS paid_orders,
       SUM(i.quantity * i.unit_price_cents) AS revenue_cents
FROM customers c
JOIN orders o      ON o.customer_id = c.customer_id AND o.status = 'paid'
JOIN order_items i ON i.order_id = o.order_id
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY revenue_cents DESC, c.customer_id
LIMIT 3;

SELECT p.sku, p.product_name, SUM(i.quantity) AS units
FROM order_items i
JOIN orders o   ON o.order_id = i.order_id
JOIN products p ON p.product_id = i.product_id
WHERE o.status = 'paid'
GROUP BY p.product_id, p.sku, p.product_name
ORDER BY units DESC, p.sku
LIMIT 3;

SELECT SUM(i.quantity * i.unit_price_cents) AS paid_line_cents
FROM order_items i
JOIN orders o ON o.order_id = i.order_id
WHERE o.status = 'paid';

SELECT o.order_id,
       SUM(i.quantity * i.unit_price_cents) AS line_cents,
       (SELECT SUM(p.amount_cents) FROM payments p WHERE p.order_id = o.order_id) AS paid_cents
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.order_id
HAVING line_cents <> COALESCE(paid_cents, 0)
ORDER BY o.order_id;
