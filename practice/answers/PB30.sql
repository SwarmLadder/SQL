SELECT full_name, manager_id
FROM employees
ORDER BY manager_id IS NULL, manager_id, employee_id;
