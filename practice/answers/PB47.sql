SELECT t.team_name
FROM teams t
LEFT JOIN employees e ON e.team_id = t.team_id
WHERE e.employee_id IS NULL
ORDER BY t.team_name;
