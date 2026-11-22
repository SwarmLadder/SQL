SELECT c.category_name, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
FROM order_items i
JOIN orders o     ON o.order_id = i.order_id
JOIN products p   ON p.product_id = i.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE o.status = 'paid'
GROUP BY c.category_id, c.category_name
ORDER BY revenue_cents DESC, c.category_name;
