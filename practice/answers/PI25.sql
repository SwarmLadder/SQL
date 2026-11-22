SELECT t.team_name, s.headcount
FROM (SELECT team_id, COUNT(*) AS headcount FROM employees GROUP BY team_id) AS s
JOIN teams t ON t.team_id = s.team_id
WHERE s.headcount >= 2
ORDER BY t.team_name;
