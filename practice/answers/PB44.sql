SELECT i.order_id, p.sku, i.quantity
FROM order_items i
JOIN products p ON p.product_id = i.product_id
ORDER BY i.order_id, p.sku;
