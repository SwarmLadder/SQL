WITH totals AS (
  SELECT o.customer_id, o.order_id, o.ordered_at, SUM(i.quantity * i.unit_price_cents) AS total_cents
  FROM orders o JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.order_id, o.customer_id, o.ordered_at
)
SELECT customer_id, order_id, total_cents,
  SUM(total_cents) OVER (PARTITION BY customer_id ORDER BY ordered_at, order_id) AS running_cents
FROM totals
ORDER BY customer_id, ordered_at, order_id;
