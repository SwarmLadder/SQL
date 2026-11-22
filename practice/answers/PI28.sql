WITH monthly AS (
  SELECT SUBSTR(o.ordered_at, 1, 7) AS month, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM orders o JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY month
)
SELECT month, revenue_cents
FROM monthly
WHERE revenue_cents > (SELECT AVG(revenue_cents) FROM monthly)
ORDER BY month;
