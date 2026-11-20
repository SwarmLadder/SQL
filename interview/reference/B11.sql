SELECT p.sku,p.product_name FROM products p WHERE NOT EXISTS(SELECT 1 FROM order_items i WHERE i.product_id=p.product_id) ORDER BY p.sku;
