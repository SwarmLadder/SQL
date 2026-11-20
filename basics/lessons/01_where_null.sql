SELECT * FROM orders WHERE status = 'paid';
SELECT product_name, unit_price_cents
FROM products WHERE unit_price_cents BETWEEN 300 AND 7000 AND active = 1;
SELECT customer_id, full_name FROM customers
WHERE city IN ('Bucharest', 'Sibiu');
SELECT employee_id, full_name FROM employees WHERE manager_id IS NULL;
