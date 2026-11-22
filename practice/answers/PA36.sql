SELECT employee_id, full_name
FROM employees
WHERE manager_id IS NOT 1
ORDER BY employee_id;
