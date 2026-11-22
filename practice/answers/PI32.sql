SELECT order_id, status
FROM orders
ORDER BY CASE status WHEN 'pending' THEN 0 WHEN 'paid' THEN 1 ELSE 2 END, order_id;
