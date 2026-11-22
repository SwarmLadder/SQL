SELECT COUNT(DISTINCT customer_id) AS paying_customers
FROM orders
WHERE status = 'paid';
