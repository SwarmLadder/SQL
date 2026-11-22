WITH totals AS (
  SELECT o.customer_id, SUM(p.amount_cents) AS lifetime_cents
  FROM payments p
  JOIN orders o ON o.order_id = p.order_id
  GROUP BY o.customer_id
)
SELECT customer_id, lifetime_cents,
  DENSE_RANK() OVER (ORDER BY lifetime_cents DESC) AS spend_rank
FROM totals
ORDER BY spend_rank, customer_id;
