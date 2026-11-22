SELECT SUBSTR(paid_at, 1, 7) AS month,
  SUM(CASE WHEN method = 'card' THEN amount_cents ELSE 0 END) AS card_cents,
  SUM(CASE WHEN method = 'transfer' THEN amount_cents ELSE 0 END) AS transfer_cents,
  SUM(CASE WHEN method = 'cash' THEN amount_cents ELSE 0 END) AS cash_cents
FROM payments
GROUP BY month
ORDER BY month;
