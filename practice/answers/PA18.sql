WITH items AS (
  SELECT order_id, SUM(quantity * unit_price_cents) AS items_cents FROM order_items GROUP BY order_id
), paid AS (
  SELECT order_id, SUM(amount_cents) AS paid_cents FROM payments GROUP BY order_id
)
SELECT o.order_id, o.status, COALESCE(items.items_cents, 0) AS items_cents,
  COALESCE(paid.paid_cents, 0) AS paid_cents,
  CASE
    WHEN o.status = 'paid' AND paid.order_id IS NULL THEN 'missing_payment'
    WHEN o.status = 'paid' AND paid.paid_cents <> COALESCE(items.items_cents, 0) THEN 'mismatch'
    WHEN o.status = 'paid' THEN 'ok'
    WHEN paid.order_id IS NOT NULL THEN 'unexpected_payment'
    ELSE 'not_due'
  END AS flag
FROM orders o
LEFT JOIN items ON items.order_id = o.order_id
LEFT JOIN paid ON paid.order_id = o.order_id
ORDER BY o.order_id;
