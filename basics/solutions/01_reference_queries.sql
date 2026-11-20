-- 1. Active products.
SELECT sku, product_name FROM products WHERE active=1 ORDER BY sku;
-- 2. Pending or cancelled orders.
SELECT order_id,status FROM orders WHERE status IN ('pending','cancelled') ORDER BY order_id;
-- 3. Products cheaper than 500 cents.
SELECT sku,unit_price_cents FROM products WHERE unit_price_cents<500 ORDER BY unit_price_cents;
-- 4. Latest orders.
SELECT order_id,ordered_at FROM orders ORDER BY ordered_at DESC,order_id DESC LIMIT 3;
-- 5. Distinct cities.
SELECT DISTINCT city FROM customers ORDER BY city;
-- 6. Paid count by customer, including no paid orders.
SELECT c.customer_id,c.full_name,COUNT(o.order_id) AS paid_orders
FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id AND o.status='paid'
GROUP BY c.customer_id,c.full_name ORDER BY c.customer_id;
-- 7. Employees and managers.
SELECT e.full_name AS employee,m.full_name AS manager
FROM employees e LEFT JOIN employees m ON m.employee_id=e.manager_id ORDER BY e.employee_id;
-- 8. Never-ordered products.
SELECT p.sku,p.product_name FROM products p
WHERE NOT EXISTS (SELECT 1 FROM order_items i WHERE i.product_id=p.product_id)
ORDER BY p.sku;
