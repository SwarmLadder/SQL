SELECT product_name, unit_price_cents
FROM products
WHERE unit_price_cents > (SELECT AVG(unit_price_cents) FROM products)
ORDER BY unit_price_cents DESC;
SELECT full_name FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders WHERE status='paid')
ORDER BY full_name;
SELECT o.order_id, t.order_total_cents
FROM orders o JOIN (
  SELECT order_id, SUM(quantity*unit_price_cents) AS order_total_cents
  FROM order_items GROUP BY order_id
) t ON t.order_id = o.order_id
ORDER BY t.order_total_cents DESC LIMIT 5;
