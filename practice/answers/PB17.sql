SELECT o.order_id, c.full_name, o.ordered_at
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;
