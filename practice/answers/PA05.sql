WITH RECURSIVE chain(employee_id, full_name, depth) AS (
  SELECT employee_id, full_name, 0 FROM employees WHERE manager_id IS NULL
  UNION ALL
  SELECT e.employee_id, e.full_name, chain.depth + 1
  FROM employees e
  JOIN chain ON e.manager_id = chain.employee_id
)
SELECT employee_id, full_name, depth
FROM chain
ORDER BY depth, employee_id;
