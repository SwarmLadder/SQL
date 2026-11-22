WITH monthly AS (
  SELECT strftime('%Y-%m', paid_at) AS month, SUM(amount_cents) AS revenue_cents
  FROM payments
  GROUP BY month
)
SELECT month, revenue_cents,
  SUM(revenue_cents) OVER (ORDER BY month) AS running_cents
FROM monthly
ORDER BY month;
