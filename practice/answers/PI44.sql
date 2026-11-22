SELECT i.product_id FROM order_items i JOIN orders o ON o.order_id = i.order_id WHERE o.status = 'pending'
INTERSECT
SELECT i.product_id FROM order_items i JOIN orders o ON o.order_id = i.order_id WHERE o.status = 'paid'
ORDER BY product_id;
