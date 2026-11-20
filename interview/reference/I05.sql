SELECT c.customer_id,c.full_name,MAX(o.ordered_at) AS last_order_date FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id GROUP BY c.customer_id,c.full_name ORDER BY c.customer_id;
