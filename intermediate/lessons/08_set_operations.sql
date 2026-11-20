SELECT customer_id FROM orders WHERE status='paid'
UNION SELECT customer_id FROM orders WHERE status='pending'
ORDER BY customer_id;
SELECT customer_id FROM orders WHERE status='paid'
INTERSECT SELECT customer_id FROM orders WHERE status='pending'
ORDER BY customer_id;
SELECT customer_id FROM customers
EXCEPT SELECT customer_id FROM orders WHERE status='paid'
ORDER BY customer_id;
SELECT city FROM customers WHERE joined_at < '2026-04-01'
UNION ALL SELECT city FROM customers WHERE joined_at >= '2026-04-01'
ORDER BY city;
