WITH ranked AS (
  SELECT team_id, full_name, salary_cents,
    DENSE_RANK() OVER (PARTITION BY team_id ORDER BY salary_cents DESC) AS dr
  FROM employees
)
SELECT team_id, full_name, salary_cents
FROM ranked
WHERE dr = 2
ORDER BY team_id, full_name;
