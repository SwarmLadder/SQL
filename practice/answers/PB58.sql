SELECT c.city, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
FROM customers c
JOIN orders o      ON o.customer_id = c.customer_id
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY c.city
ORDER BY revenue_cents DESC, c.city;
