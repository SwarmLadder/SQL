SELECT category_id, COUNT(*) AS product_count
FROM products
GROUP BY category_id
HAVING COUNT(*) > 1
ORDER BY category_id;
