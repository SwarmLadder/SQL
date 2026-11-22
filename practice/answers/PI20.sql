WITH monthly AS (
  SELECT strftime('%Y-%m', o.ordered_at) AS month,
         SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM orders o
  JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY month
)
SELECT month, revenue_cents,
  revenue_cents - LAG(revenue_cents) OVER (ORDER BY month) AS change_cents
FROM monthly
ORDER BY month;
