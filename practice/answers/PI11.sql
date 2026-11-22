WITH ranked AS (
  SELECT e.*, ROW_NUMBER() OVER (PARTITION BY e.team_id ORDER BY e.salary_cents DESC, e.employee_id) AS rn
  FROM employees e
)
SELECT t.team_name, r.full_name, r.salary_cents
FROM ranked r
JOIN teams t ON t.team_id = r.team_id
WHERE r.rn <= 2
ORDER BY t.team_name, r.salary_cents DESC;
