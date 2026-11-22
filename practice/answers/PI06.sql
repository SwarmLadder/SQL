SELECT customer_id FROM orders WHERE status = 'pending'
INTERSECT
SELECT customer_id FROM orders WHERE status = 'paid'
ORDER BY customer_id;
