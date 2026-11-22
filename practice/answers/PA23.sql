SELECT order_id FROM orders WHERE customer_id = 2
UNION ALL
SELECT order_id FROM orders WHERE status = 'cancelled' AND customer_id <> 2
ORDER BY order_id;
