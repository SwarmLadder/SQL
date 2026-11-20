-- 1. Verify an indexed lookup plan.
EXPLAIN QUERY PLAN SELECT * FROM orders WHERE customer_id=1 ORDER BY ordered_at;
-- 2. Recursive employee hierarchy (root-to-leaf).
WITH RECURSIVE tree(employee_id,name,manager_id,depth) AS (
 SELECT employee_id,full_name,manager_id,0 FROM employees WHERE manager_id IS NULL
 UNION ALL
 SELECT e.employee_id,e.full_name,e.manager_id,t.depth+1
 FROM employees e JOIN tree t ON e.manager_id=t.employee_id WHERE t.depth<10
)
SELECT * FROM tree ORDER BY depth,employee_id;
-- 3. Correct paid-order payment reconciliation.
WITH items AS (
 SELECT order_id,SUM(quantity*unit_price_cents) AS total FROM order_items GROUP BY order_id
), pay AS (
 SELECT order_id,SUM(amount_cents) AS total FROM payments GROUP BY order_id
)
SELECT o.order_id,items.total,pay.total,
       CASE WHEN items.total=pay.total THEN 'MATCH' ELSE 'MISMATCH' END AS status
FROM orders o JOIN items ON items.order_id=o.order_id
LEFT JOIN pay ON pay.order_id=o.order_id
WHERE o.status='paid' ORDER BY o.order_id;
-- 4. NULL-safe anti-match.
SELECT p.sku FROM products p
WHERE NOT EXISTS(SELECT 1 FROM order_items i WHERE i.product_id=p.product_id)
ORDER BY p.sku;
-- 5. Atomic upsert of a counter.
CREATE TABLE counter(name TEXT PRIMARY KEY,total INTEGER NOT NULL CHECK(total>=0));
INSERT INTO counter VALUES('books',1);
INSERT INTO counter(name,total) VALUES('books',2)
ON CONFLICT(name) DO UPDATE SET total=counter.total+excluded.total;
SELECT * FROM counter;
-- 6. Unique request record; repeated identical insert is ignored.
CREATE TABLE requests(request_key TEXT PRIMARY KEY,payload TEXT NOT NULL);
INSERT INTO requests VALUES ('k1','amount=5');
INSERT INTO requests VALUES ('k1','amount=5') ON CONFLICT(request_key) DO NOTHING;
SELECT COUNT(*) FROM requests;
-- 7. Running paid revenue.
WITH monthly AS (
 SELECT SUBSTR(o.ordered_at,1,7) AS month,SUM(i.quantity*i.unit_price_cents) AS total
 FROM orders o JOIN order_items i ON i.order_id=o.order_id
 WHERE o.status='paid' GROUP BY SUBSTR(o.ordered_at,1,7)
)
SELECT month,total,SUM(total) OVER(ORDER BY month ROWS UNBOUNDED PRECEDING) AS running
FROM monthly ORDER BY month;
-- 8. A schema constraint to prevent bad quantity values.
CREATE TABLE demo_stock(sku TEXT PRIMARY KEY,quantity INTEGER NOT NULL CHECK(quantity>=0));
INSERT INTO demo_stock VALUES('P01',5);
SELECT * FROM demo_stock;
