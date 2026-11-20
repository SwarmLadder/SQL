SELECT order_id, status,
CASE status WHEN 'paid' THEN 'Completed'
            WHEN 'cancelled' THEN 'Closed'
            ELSE 'Action needed' END AS workflow
FROM orders ORDER BY order_id;
SELECT c.city,
       COUNT(*) AS customers,
       SUM(CASE WHEN c.joined_at >= '2026-03-01' THEN 1 ELSE 0 END) AS recent_customers
FROM customers c GROUP BY c.city ORDER BY c.city;
SELECT customer_id,
       SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) AS paid_orders,
       SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending_orders
FROM orders GROUP BY customer_id ORDER BY customer_id;
