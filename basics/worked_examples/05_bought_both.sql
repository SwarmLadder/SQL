-- Worked example B5 · Customers who bought from both categories
-- Examples from basics/worked_examples/05_bought_both.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/worked_examples/05_bought_both.sql
INSERT INTO orders VALUES (120, 1, '2026-08-10', 'paid');
INSERT INTO order_items VALUES (120, 7, 1, 5500);

SELECT DISTINCT o.customer_id
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
JOIN products p    ON p.product_id = i.product_id
JOIN categories c  ON c.category_id = p.category_id
WHERE o.status = 'paid'
  AND c.category_name = 'Books'
  AND c.category_name = 'Electronics';

SELECT o.customer_id,
       COUNT(DISTINCT c.category_name) AS categories_bought
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
JOIN products p    ON p.product_id = i.product_id
JOIN categories c  ON c.category_id = p.category_id
WHERE o.status = 'paid'
  AND c.category_name IN ('Books', 'Electronics')
GROUP BY o.customer_id
HAVING COUNT(DISTINCT c.category_name) = 2
ORDER BY o.customer_id;

SELECT o.customer_id, c.category_name, COUNT(*) AS lines
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
JOIN products p    ON p.product_id = i.product_id
JOIN categories c  ON c.category_id = p.category_id
WHERE o.status = 'paid' AND c.category_name IN ('Books', 'Electronics')
GROUP BY o.customer_id, c.category_name
ORDER BY o.customer_id, c.category_name;
