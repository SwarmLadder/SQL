SELECT p.sku, SUM(i.quantity) AS units
FROM order_items i
JOIN orders o   ON o.order_id = i.order_id
JOIN products p ON p.product_id = i.product_id
WHERE o.status = 'paid'
GROUP BY p.product_id, p.sku
ORDER BY units DESC, p.sku
LIMIT 3;
