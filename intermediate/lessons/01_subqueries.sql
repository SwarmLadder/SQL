-- 01 · Scalar, IN, and derived-table subqueries
-- Examples from intermediate/lessons/01_subqueries.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/lessons/01_subqueries.sql
SELECT sku, product_name, unit_price_cents,
       (SELECT AVG(unit_price_cents) FROM products) AS avg_price
FROM products
WHERE unit_price_cents > (SELECT AVG(unit_price_cents) FROM products)
ORDER BY unit_price_cents DESC;

SELECT customer_id, full_name
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders WHERE status = 'pending')
ORDER BY customer_id;

SELECT full_name
FROM employees
WHERE employee_id NOT IN (SELECT manager_id FROM employees);

SELECT full_name
FROM employees
WHERE employee_id NOT IN (SELECT manager_id FROM employees WHERE manager_id IS NOT NULL)
ORDER BY employee_id;

SELECT t.team_name, s.headcount, s.avg_salary_cents
FROM (SELECT team_id, COUNT(*) AS headcount, ROUND(AVG(salary_cents)) AS avg_salary_cents
      FROM employees
      GROUP BY team_id) AS s
JOIN teams t ON t.team_id = s.team_id
ORDER BY s.avg_salary_cents DESC;

SELECT e.full_name, e.team_id, e.salary_cents
FROM employees e
WHERE e.salary_cents > (SELECT AVG(x.salary_cents)
                        FROM employees x
                        WHERE x.team_id = e.team_id)
ORDER BY e.team_id, e.salary_cents DESC;
