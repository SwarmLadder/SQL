SELECT o.order_id, c.full_name, p.product_name, oi.quantity
FROM orders AS o
JOIN customers AS c ON c.customer_id = o.customer_id
JOIN order_items AS oi ON oi.order_id = o.order_id
JOIN products AS p ON p.product_id = oi.product_id
ORDER BY o.order_id, p.product_name;
SELECT c.full_name, SUM(oi.quantity * oi.unit_price_cents) AS paid_total_cents
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'paid'
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.full_name
ORDER BY paid_total_cents DESC;
-- Aggregate the payments and line totals separately to avoid row multiplication.
WITH lines AS (
  SELECT order_id, SUM(quantity * unit_price_cents) AS total_cents
  FROM order_items GROUP BY order_id
), paid AS (
  SELECT order_id, SUM(amount_cents) AS paid_cents
  FROM payments GROUP BY order_id
)
SELECT o.order_id, o.status, l.total_cents, COALESCE(p.paid_cents, 0) AS paid_cents
FROM orders o JOIN lines l ON l.order_id=o.order_id
LEFT JOIN paid p ON p.order_id=o.order_id ORDER BY o.order_id;
