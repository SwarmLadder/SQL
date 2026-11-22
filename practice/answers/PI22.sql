WITH items AS (
  SELECT order_id, SUM(quantity * unit_price_cents) AS items_cents FROM order_items GROUP BY order_id
), paid AS (
  SELECT order_id, SUM(amount_cents) AS paid_cents FROM payments GROUP BY order_id
)
SELECT o.order_id, items.items_cents, COALESCE(paid.paid_cents, 0) AS paid_cents
FROM orders o
JOIN items ON items.order_id = o.order_id
LEFT JOIN paid ON paid.order_id = o.order_id
WHERE o.status = 'paid' AND items.items_cents <> COALESCE(paid.paid_cents, 0)
ORDER BY o.order_id;
