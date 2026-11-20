-- One set-based query avoids one query per customer.
SELECT c.customer_id,c.full_name,COUNT(o.order_id) AS order_count
FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id
GROUP BY c.customer_id,c.full_name ORDER BY c.customer_id;
EXPLAIN QUERY PLAN
SELECT c.customer_id,c.full_name,COUNT(o.order_id)
FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id
GROUP BY c.customer_id,c.full_name ORDER BY c.customer_id;
