SELECT SUBSTR(ordered_at, 1, 7) AS month, COUNT(*) AS order_count
FROM orders
GROUP BY month
ORDER BY month;
