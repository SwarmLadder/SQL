SELECT team_id, COUNT(*) AS staff,
  SUM(CASE WHEN salary_cents > 8000000 THEN 1 ELSE 0 END) AS high_earners
FROM employees
GROUP BY team_id
ORDER BY team_id;
