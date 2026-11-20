SELECT c.full_name, o.order_id
FROM customers AS c LEFT JOIN orders AS o ON o.customer_id = c.customer_id
ORDER BY c.customer_id, o.order_id;
SELECT p.product_name, oi.order_id
FROM products AS p LEFT JOIN order_items AS oi ON oi.product_id = p.product_id
ORDER BY p.product_id, oi.order_id;
SELECT e.full_name, m.full_name AS manager
FROM employees AS e LEFT JOIN employees AS m ON m.employee_id = e.manager_id
ORDER BY e.employee_id;
SELECT c.full_name
FROM customers AS c LEFT JOIN orders AS o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;
