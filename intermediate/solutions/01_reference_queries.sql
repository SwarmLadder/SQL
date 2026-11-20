-- 1. Customers with paid orders.
SELECT c.customer_id,c.full_name FROM customers c
WHERE EXISTS(SELECT 1 FROM orders o WHERE o.customer_id=c.customer_id AND o.status='paid')
ORDER BY c.customer_id;
-- 2. Products above the average price.
SELECT sku,unit_price_cents FROM products
WHERE unit_price_cents>(SELECT AVG(unit_price_cents) FROM products)
ORDER BY unit_price_cents DESC;
-- 3. Counts by status in one row.
SELECT SUM(CASE WHEN status='paid' THEN 1 ELSE 0 END) AS paid,
       SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) AS pending,
       SUM(CASE WHEN status='cancelled' THEN 1 ELSE 0 END) AS cancelled
FROM orders;
-- 4. Top two employees in each team.
WITH ranked AS (
 SELECT e.full_name,t.team_name,e.salary_cents,
        ROW_NUMBER() OVER(PARTITION BY e.team_id ORDER BY e.salary_cents DESC,e.employee_id) AS rn
 FROM employees e JOIN teams t ON t.team_id=e.team_id
)
SELECT full_name,team_name,salary_cents FROM ranked WHERE rn<=2 ORDER BY team_name,rn;
-- 5. First order and latest order for each customer.
SELECT c.customer_id,c.full_name,MIN(o.ordered_at) AS first_order,MAX(o.ordered_at) AS latest_order
FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id
GROUP BY c.customer_id,c.full_name ORDER BY c.customer_id;
-- 6. Paid revenue by month.
SELECT SUBSTR(o.ordered_at,1,7) AS month,
       SUM(i.quantity*i.unit_price_cents) AS revenue_cents
FROM orders o JOIN order_items i ON i.order_id=o.order_id
WHERE o.status='paid' GROUP BY SUBSTR(o.ordered_at,1,7) ORDER BY month;
-- 7. Customers with pending AND paid orders.
SELECT customer_id FROM orders WHERE status='pending'
INTERSECT SELECT customer_id FROM orders WHERE status='paid'
ORDER BY customer_id;
-- 8. Savepoint rollback (changes do not persist).
SAVEPOINT practice;
UPDATE products SET unit_price_cents=9999 WHERE product_id=1;
ROLLBACK TO practice;
RELEASE practice;
SELECT product_id,unit_price_cents FROM products WHERE product_id=1;
