SELECT NULL = NULL AS unknown_equality, NULL IS NULL AS known_missing;
SELECT c.customer_id FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id=c.customer_id)
ORDER BY c.customer_id;
SELECT o.order_id, COALESCE(p.method,'unpaid') AS payment_method
FROM orders o LEFT JOIN payments p ON p.order_id=o.order_id
ORDER BY o.order_id;
-- Demonstrate NOT IN with NULL using fixed literals.
SELECT 1 AS selected WHERE 1 NOT IN (2, NULL);
SELECT 1 AS selected WHERE NOT EXISTS (SELECT 1 WHERE 2=1);
