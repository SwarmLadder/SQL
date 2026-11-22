SELECT p.sku, p.product_name, c.category_name
FROM products p
JOIN categories c ON c.category_id = p.category_id
ORDER BY p.sku;
