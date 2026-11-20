SELECT status, COUNT(*) AS orders_count
FROM orders GROUP BY status ORDER BY status;
SELECT category_id, COUNT(*) AS products_count
FROM products GROUP BY category_id ORDER BY category_id;
SELECT customer_id, COUNT(*) AS order_count
FROM orders GROUP BY customer_id HAVING COUNT(*) > 1 ORDER BY customer_id;
SELECT method, SUM(amount_cents) AS revenue_cents
FROM payments GROUP BY method ORDER BY revenue_cents DESC;
