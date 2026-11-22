SELECT order_id, status
FROM orders
WHERE status IN ('pending', 'cancelled')
ORDER BY order_id;
