SELECT e.full_name, t.team_name, e.salary_cents,
       ROW_NUMBER() OVER (PARTITION BY e.team_id ORDER BY e.salary_cents DESC, e.employee_id) AS position
FROM employees e JOIN teams t ON t.team_id=e.team_id
ORDER BY t.team_name, position;
SELECT product_name, unit_price_cents,
       RANK() OVER (ORDER BY unit_price_cents DESC) AS price_rank,
       DENSE_RANK() OVER (ORDER BY unit_price_cents DESC) AS dense_price_rank
FROM products ORDER BY price_rank;
WITH ranked AS (
  SELECT full_name, team_id, salary_cents,
         ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY salary_cents DESC, employee_id) AS rn
  FROM employees
)
SELECT full_name, team_id, salary_cents FROM ranked WHERE rn = 1 ORDER BY team_id;
