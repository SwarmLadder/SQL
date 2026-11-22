-- 06 · INNER JOIN relationships
-- Examples from basics/lessons/06_joins.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/lessons/06_joins.sql
SELECT o.order_id, o.ordered_at, c.full_name, c.city
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'paid'
ORDER BY o.order_id;

SELECT i.order_id, p.sku, p.product_name, c.category_name, i.quantity
FROM order_items i
JOIN products p   ON p.product_id = i.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE i.order_id IN (101, 103, 105)
ORDER BY i.order_id, p.sku;

SELECT o.order_id, c.full_name, i.product_id, i.quantity
FROM orders o
JOIN customers c   ON c.customer_id = o.customer_id
JOIN order_items i ON i.order_id = o.order_id
WHERE o.customer_id = 1
ORDER BY o.order_id, i.product_id;

SELECT c.full_name,
       COUNT(*)                   AS joined_rows,
       COUNT(DISTINCT o.order_id) AS orders,
       SUM(i.quantity * i.unit_price_cents) AS item_cents
FROM orders o
JOIN customers c   ON c.customer_id = o.customer_id
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY c.customer_id, c.full_name
ORDER BY item_cents DESC, c.full_name;

SELECT c.category_name, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
FROM order_items i
JOIN orders o     ON o.order_id = i.order_id
JOIN products p   ON p.product_id = i.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE o.status = 'paid'
GROUP BY c.category_id, c.category_name
ORDER BY revenue_cents DESC;
