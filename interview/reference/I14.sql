SELECT customer_id FROM orders WHERE status='paid' INTERSECT SELECT customer_id FROM orders WHERE status='pending' ORDER BY customer_id;
