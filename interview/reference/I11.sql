SELECT customer_id,MIN(ordered_at) AS first_paid_date FROM orders WHERE status='paid' GROUP BY customer_id ORDER BY customer_id;
