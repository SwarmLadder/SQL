SELECT method,SUM(amount_cents) AS total_cents FROM payments GROUP BY method ORDER BY method;
