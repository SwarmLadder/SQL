WITH monthly AS (
  SELECT strftime('%Y-%m', paid_at) AS month, SUM(amount_cents) AS revenue_cents
  FROM payments GROUP BY month
)
SELECT month,
  ROUND(AVG(revenue_cents) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)) AS moving_avg_3
FROM monthly
ORDER BY month;
