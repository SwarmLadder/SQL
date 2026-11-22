SELECT t.team_name, e.full_name,
  RANK() OVER (PARTITION BY e.team_id ORDER BY e.salary_cents DESC) AS salary_rank
FROM employees e
JOIN teams t ON t.team_id = e.team_id
ORDER BY t.team_name, salary_rank, e.full_name;
