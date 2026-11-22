SELECT customer_id FROM orders WHERE status = 'pending'
UNION
SELECT o.customer_id FROM payments p JOIN orders o ON o.order_id = p.order_id WHERE p.method = 'transfer'
ORDER BY customer_id;
