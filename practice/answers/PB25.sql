SELECT order_id, customer_id
FROM orders
WHERE status = 'paid' AND (customer_id = 1 OR customer_id = 2)
ORDER BY order_id;
