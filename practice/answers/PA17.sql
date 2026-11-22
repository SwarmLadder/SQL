SELECT e.employee_id, e.full_name
FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM employees r WHERE r.manager_id = e.employee_id)
ORDER BY e.employee_id;
