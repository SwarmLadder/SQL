WITH RECURSIVE months(d) AS (
  SELECT '2026-01-01'
  UNION ALL
  SELECT date(d, '+1 month') FROM months WHERE d < '2026-12-01'
), received AS (
  SELECT strftime('%Y-%m', paid_at) AS month, SUM(amount_cents) AS cents FROM payments GROUP BY month
)
SELECT strftime('%Y-%m', m.d) AS month, COALESCE(r.cents, 0) AS received_cents
FROM months m
LEFT JOIN received r ON r.month = strftime('%Y-%m', m.d)
ORDER BY month;
