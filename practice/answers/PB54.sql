SELECT o.order_id, c.full_name, SUM(i.quantity * i.unit_price_cents) AS total_cents
FROM orders o
JOIN customers c   ON c.customer_id = o.customer_id
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.order_id, c.full_name
ORDER BY total_cents DESC, o.order_id
LIMIT 3;
