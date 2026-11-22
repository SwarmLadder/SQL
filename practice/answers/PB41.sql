SELECT product_id, SUM(quantity) AS units
FROM order_items
GROUP BY product_id
HAVING SUM(quantity) >= 3
ORDER BY units DESC, product_id;
