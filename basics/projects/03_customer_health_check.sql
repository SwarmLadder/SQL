-- Customer Health Check: reference solution. Runs on a fresh sample database.

-- Ticket 1: customer directory with order activity (zero for customers without orders).
SELECT c.customer_id, c.full_name, c.city,
       COUNT(o.order_id) AS orders,
       SUM(CASE WHEN o.status = 'paid' THEN 1 ELSE 0 END) AS paid_orders,
       MAX(o.ordered_at) AS last_order
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name, c.city
ORDER BY c.customer_id;

-- Ticket 2: customers to follow up: they ordered but never completed a payment.
SELECT c.customer_id, c.full_name, c.email
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name, c.email
HAVING SUM(CASE WHEN o.status = 'paid' THEN 1 ELSE 0 END) = 0
ORDER BY c.customer_id;

-- Ticket 3a: data quality: inactive products that appear on paid orders.
SELECT p.sku, p.product_name, i.order_id
FROM order_items i
JOIN products p ON p.product_id = i.product_id
JOIN orders o   ON o.order_id = i.order_id
WHERE p.active = 0 AND o.status = 'paid'
ORDER BY p.sku, i.order_id;

-- Ticket 3b: data quality: orders without any order line.
SELECT o.order_id, o.status
FROM orders o
LEFT JOIN order_items i ON i.order_id = o.order_id
WHERE i.order_id IS NULL
ORDER BY o.order_id;

-- Ticket 4: city summary, biggest paid revenue first.
SELECT c.city,
       COUNT(DISTINCT c.customer_id) AS customers,
       COALESCE(SUM(CASE WHEN o.status = 'paid' THEN i.quantity * i.unit_price_cents END), 0) AS paid_cents
FROM customers c
LEFT JOIN orders o      ON o.customer_id = c.customer_id
LEFT JOIN order_items i ON i.order_id = o.order_id
GROUP BY c.city
ORDER BY paid_cents DESC, c.city;
