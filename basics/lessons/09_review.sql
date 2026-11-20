SELECT o.order_id, c.full_name,
       SUM(oi.quantity * oi.unit_price_cents) AS order_total_cents
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.order_id, c.full_name
ORDER BY order_total_cents DESC, o.order_id;
SELECT o.status, COUNT(*) AS order_count
FROM orders AS o GROUP BY o.status ORDER BY o.status;
SELECT p.product_name, SUM(oi.quantity) AS units
FROM products AS p JOIN order_items AS oi ON oi.product_id = p.product_id
JOIN orders AS o ON o.order_id = oi.order_id
WHERE o.status = 'paid'
GROUP BY p.product_id, p.product_name
ORDER BY units DESC, p.product_name LIMIT 5;
