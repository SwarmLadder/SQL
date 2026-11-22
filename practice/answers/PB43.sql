SELECT t.team_name, e.full_name
FROM employees e
JOIN teams t ON t.team_id = e.team_id
ORDER BY t.team_name, e.full_name;
