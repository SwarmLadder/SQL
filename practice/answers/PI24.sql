SELECT sku, product_name
FROM products
WHERE product_id IN (
  SELECT i.product_id FROM order_items i JOIN orders o ON o.order_id = i.order_id WHERE o.status = 'paid'
)
ORDER BY sku;
