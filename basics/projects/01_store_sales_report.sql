-- Paid order totals, grouped at order grain.
SELECT o.order_id, c.full_name AS customer,
       SUM(i.quantity * i.unit_price_cents) AS revenue_cents
FROM orders o
JOIN customers c ON c.customer_id=o.customer_id
JOIN order_items i ON i.order_id=o.order_id
WHERE o.status='paid'
GROUP BY o.order_id,c.full_name
ORDER BY revenue_cents DESC,o.order_id;
-- Paid product quantities.
SELECT p.sku,p.product_name,SUM(i.quantity) AS units_sold
FROM products p JOIN order_items i ON i.product_id=p.product_id
JOIN orders o ON o.order_id=i.order_id
WHERE o.status='paid'
GROUP BY p.product_id,p.sku,p.product_name
ORDER BY units_sold DESC,p.sku;
-- Never ordered at all.
SELECT p.sku,p.product_name FROM products p
WHERE NOT EXISTS(SELECT 1 FROM order_items i WHERE i.product_id=p.product_id)
ORDER BY p.sku;
