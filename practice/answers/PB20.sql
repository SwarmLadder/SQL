SELECT o.order_id, COUNT(*) AS line_count,
       SUM(i.quantity * i.unit_price_cents) AS total_cents
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.order_id
ORDER BY o.order_id;
