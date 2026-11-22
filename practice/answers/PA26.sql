WITH RECURSIVE chain(employee_id, full_name, manager_id, level) AS (
  SELECT employee_id, full_name, manager_id, 0 FROM employees WHERE employee_id = 8
  UNION ALL
  SELECT m.employee_id, m.full_name, m.manager_id, chain.level + 1
  FROM employees m JOIN chain ON m.employee_id = chain.manager_id
)
SELECT level, full_name FROM chain ORDER BY level;
