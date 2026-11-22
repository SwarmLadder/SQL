SELECT DISTINCT c.customer_id, c.full_name
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items i ON i.order_id = o.order_id
JOIN products p ON p.product_id = i.product_id
JOIN categories cat ON cat.category_id = p.category_id
WHERE cat.category_name = 'Books'
ORDER BY c.customer_id;
