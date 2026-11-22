WITH paid AS (
  SELECT o.customer_id, SUM(p.amount_cents) AS lifetime_cents
  FROM payments p
  JOIN orders o ON o.order_id = p.order_id
  GROUP BY o.customer_id
)
SELECT c.customer_id, c.full_name, paid.lifetime_cents
FROM paid
JOIN customers c ON c.customer_id = paid.customer_id
ORDER BY paid.lifetime_cents DESC, c.customer_id;
