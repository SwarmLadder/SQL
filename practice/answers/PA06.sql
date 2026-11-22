WITH RECURSIVE chain(employee_id, path, depth) AS (
  SELECT employee_id, full_name, 0 FROM employees WHERE manager_id IS NULL
  UNION ALL
  SELECT e.employee_id, chain.path || ' > ' || e.full_name, chain.depth + 1
  FROM employees e
  JOIN chain ON e.manager_id = chain.employee_id
  WHERE chain.depth < 1
    AND instr(chain.path, e.full_name) = 0
)
SELECT employee_id, path
FROM chain
ORDER BY path;
