SELECT method, SUM(amount_cents) AS paid_cents
FROM payments
GROUP BY method
ORDER BY method;
