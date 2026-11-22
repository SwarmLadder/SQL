WITH RECURSIVE team(employee_id, full_name) AS (
  SELECT employee_id, full_name FROM employees WHERE manager_id = 1
  UNION ALL
  SELECT e.employee_id, e.full_name FROM employees e JOIN team t ON e.manager_id = t.employee_id
)
SELECT employee_id, full_name FROM team ORDER BY employee_id;
