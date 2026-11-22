SELECT SUBSTR(paid_at, 1, 7) AS month, SUM(amount_cents) AS received_cents
FROM payments
GROUP BY month
ORDER BY month;
