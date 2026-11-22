SELECT order_id, product_id, quantity * unit_price_cents AS line_cents
FROM order_items
ORDER BY order_id, product_id;
