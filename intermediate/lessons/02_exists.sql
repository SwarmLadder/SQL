SELECT c.customer_id, c.full_name
FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.status='paid'
) ORDER BY c.customer_id;
SELECT p.product_name FROM products p
WHERE NOT EXISTS (
  SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id
) ORDER BY p.product_name;
SELECT e.full_name FROM employees e
WHERE EXISTS (
  SELECT 1 FROM employees child WHERE child.manager_id=e.employee_id
) ORDER BY e.full_name;
