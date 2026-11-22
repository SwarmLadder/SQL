SELECT t.team_id, t.team_name
FROM teams t
WHERE NOT EXISTS (SELECT 1 FROM employees e WHERE e.team_id = t.team_id)
ORDER BY t.team_id;
