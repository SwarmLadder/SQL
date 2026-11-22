SELECT employee_id, full_name, salary_cents
FROM employees
WHERE manager_id IS NOT NULL AND salary_cents < 8000000
ORDER BY employee_id;
