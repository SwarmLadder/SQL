-- Correlated existence test.
SELECT c.customer_id FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id=c.customer_id AND o.status='paid')
ORDER BY c.customer_id;
-- Equivalent set-based join with DISTINCT.
SELECT DISTINCT c.customer_id FROM customers c
JOIN orders o ON o.customer_id=c.customer_id WHERE o.status='paid'
ORDER BY c.customer_id;
-- Avoid multiplying item totals by joining unrelated detail records.
WITH item_totals AS (
  SELECT order_id,SUM(quantity*unit_price_cents) AS total_cents
  FROM order_items GROUP BY order_id
), payment_totals AS (
  SELECT order_id,SUM(amount_cents) AS paid_cents
  FROM payments GROUP BY order_id
)
SELECT o.order_id,i.total_cents,COALESCE(p.paid_cents,0) AS paid_cents
FROM orders o JOIN item_totals i ON i.order_id=o.order_id
LEFT JOIN payment_totals p ON p.order_id=o.order_id
ORDER BY o.order_id;
