SELECT o.order_id, c.full_name, o.status
FROM orders AS o JOIN customers AS c ON c.customer_id = o.customer_id
ORDER BY o.order_id;
SELECT p.product_name, c.category_name
FROM products AS p JOIN categories AS c ON c.category_id = p.category_id
ORDER BY p.product_name;
SELECT oi.order_id, p.product_name, oi.quantity
FROM order_items AS oi JOIN products AS p ON p.product_id = oi.product_id
ORDER BY oi.order_id, p.product_name;
SELECT e.full_name, t.team_name
FROM employees AS e JOIN teams AS t ON t.team_id = e.team_id
ORDER BY t.team_name, e.full_name;
