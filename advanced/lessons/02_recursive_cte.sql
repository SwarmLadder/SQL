WITH RECURSIVE org(employee_id, full_name, manager_id, depth, path) AS (
  SELECT employee_id,full_name,manager_id,0,printf('%d',employee_id)
  FROM employees WHERE manager_id IS NULL
  UNION ALL
  SELECT e.employee_id,e.full_name,e.manager_id,org.depth+1,
         org.path || '/' || e.employee_id
  FROM employees e JOIN org ON e.manager_id=org.employee_id
  WHERE org.depth < 10
)
SELECT depth, full_name, path FROM org ORDER BY path;
WITH RECURSIVE numbers(n) AS (
 SELECT 1
 UNION ALL SELECT n+1 FROM numbers WHERE n<10
)
SELECT SUM(n) AS sum_one_through_ten FROM numbers;
