WITH order_value AS (
  SELECT o.order_id, o.customer_id,
         SUM(oi.quantity * oi.unit_price_cents) AS total_cents
  FROM orders o JOIN order_items oi ON oi.order_id=o.order_id
  WHERE o.status='paid'
  GROUP BY o.order_id, o.customer_id
)
SELECT customer_id, COUNT(*) AS paid_orders, SUM(total_cents) AS revenue_cents
FROM order_value GROUP BY customer_id ORDER BY revenue_cents DESC;
WITH category_units AS (
  SELECT p.category_id, SUM(oi.quantity) AS units
  FROM products p JOIN order_items oi ON oi.product_id=p.product_id
  GROUP BY p.category_id
)
SELECT c.category_name, COALESCE(u.units,0) AS units
FROM categories c LEFT JOIN category_units u ON u.category_id=c.category_id
ORDER BY units DESC;
