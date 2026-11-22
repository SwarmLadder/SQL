SELECT customer_id FROM orders
EXCEPT
SELECT customer_id FROM orders WHERE status = 'paid'
ORDER BY customer_id;
