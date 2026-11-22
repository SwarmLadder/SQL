-- 05 · Window functions and rankings
-- Examples from intermediate/lessons/05_windows_ranking.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/lessons/05_windows_ranking.sql
SELECT full_name, team_id, salary_cents,
       ROUND(AVG(salary_cents) OVER (PARTITION BY team_id)) AS team_avg,
       ROUND(salary_cents - AVG(salary_cents) OVER (PARTITION BY team_id)) AS diff_from_team_avg,
       COUNT(*) OVER () AS all_staff
FROM employees
ORDER BY team_id, salary_cents DESC;

SELECT full_name, team_id, salary_cents,
       ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY salary_cents DESC) AS row_num
FROM employees
ORDER BY team_id, row_num;

BEGIN;
UPDATE employees SET salary_cents = 8500000 WHERE employee_id = 6;

SELECT full_name, salary_cents,
       ROW_NUMBER() OVER w AS row_number,
       RANK()       OVER w AS rank,
       DENSE_RANK() OVER w AS dense_rank
FROM employees
WINDOW w AS (ORDER BY salary_cents DESC)
ORDER BY salary_cents DESC, full_name;

ROLLBACK;

WITH ranked AS (
  SELECT e.employee_id, e.full_name, e.team_id, e.salary_cents,
         ROW_NUMBER() OVER (PARTITION BY e.team_id
                            ORDER BY e.salary_cents DESC, e.employee_id) AS rn
  FROM employees e
)
SELECT t.team_name, r.full_name, r.salary_cents
FROM ranked r
JOIN teams t ON t.team_id = r.team_id
WHERE r.rn <= 2
ORDER BY t.team_name, r.rn;

WITH revenue AS (
  SELECT o.customer_id, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM orders o
  JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.customer_id
)
SELECT customer_id, revenue_cents,
       DENSE_RANK() OVER (ORDER BY revenue_cents DESC) AS revenue_rank,
       ROUND(100.0 * revenue_cents / SUM(revenue_cents) OVER (), 1) AS pct_of_total
FROM revenue
ORDER BY revenue_rank, customer_id;

SELECT sku, unit_price_cents,
       NTILE(3) OVER (ORDER BY unit_price_cents) AS price_tercile
FROM products
ORDER BY unit_price_cents;
