SELECT e.full_name, e.team_id, e.salary_cents
FROM employees e
WHERE e.salary_cents > (SELECT AVG(x.salary_cents) FROM employees x WHERE x.team_id = e.team_id)
ORDER BY e.team_id, e.salary_cents DESC;
