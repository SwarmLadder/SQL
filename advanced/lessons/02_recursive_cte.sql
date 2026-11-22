-- 02 · Recursive CTEs and hierarchies
-- Examples from advanced/lessons/02_recursive_cte.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/lessons/02_recursive_cte.sql
WITH RECURSIVE n(i) AS (
  SELECT 1                        -- anchor
  UNION ALL
  SELECT i + 1 FROM n WHERE i < 5 -- recursive step and stop condition
)
SELECT i FROM n;

WITH RECURSIVE months(month_start) AS (
  SELECT '2026-01-01'
  UNION ALL
  SELECT date(month_start, '+1 month') FROM months WHERE month_start < '2026-09-01'
),
revenue AS (
  SELECT strftime('%Y-%m', paid_at) AS month, SUM(amount_cents) AS cents
  FROM payments GROUP BY month
)
SELECT strftime('%Y-%m', m.month_start) AS month,
       COALESCE(r.cents, 0) AS revenue_cents
FROM months m
LEFT JOIN revenue r ON r.month = strftime('%Y-%m', m.month_start)
ORDER BY month;

WITH RECURSIVE org(employee_id, full_name, manager_id, depth, path) AS (
  SELECT employee_id, full_name, manager_id, 0, full_name
  FROM employees
  WHERE manager_id IS NULL
  UNION ALL
  SELECT e.employee_id, e.full_name, e.manager_id, org.depth + 1,
         org.path || ' > ' || e.full_name
  FROM employees e
  JOIN org ON e.manager_id = org.employee_id
)
SELECT depth, full_name, path
FROM org
ORDER BY path;

WITH RECURSIVE chain(employee_id, full_name, manager_id, level) AS (
  SELECT employee_id, full_name, manager_id, 0 FROM employees WHERE employee_id = 8
  UNION ALL
  SELECT m.employee_id, m.full_name, m.manager_id, chain.level + 1
  FROM employees m
  JOIN chain ON m.employee_id = chain.manager_id
)
SELECT level, full_name FROM chain ORDER BY level;

BEGIN;
UPDATE employees SET manager_id = 2 WHERE employee_id = 1;   -- Ada now reports to Ben: a cycle

WITH RECURSIVE walk(employee_id, path, depth) AS (
  SELECT 2, '/2/', 0
  UNION ALL
  SELECT e.employee_id, walk.path || e.employee_id || '/', walk.depth + 1
  FROM employees e
  JOIN walk ON e.manager_id = walk.employee_id
  WHERE instr(walk.path, '/' || e.employee_id || '/') = 0   -- not visited yet
    AND walk.depth < 20                                        -- safety net
)
SELECT employee_id, path, depth FROM walk ORDER BY depth, employee_id;

ROLLBACK;
