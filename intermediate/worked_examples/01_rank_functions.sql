-- Worked example I1: ROW_NUMBER vs RANK vs DENSE_RANK on tied salaries.
-- Create a tie inside a transaction so the three functions disagree.
BEGIN;
UPDATE employees SET salary_cents = 8500000 WHERE employee_id = 6;  -- Fadi now earns the same as Ben

SELECT e.full_name, e.salary_cents,
       ROW_NUMBER() OVER w AS row_number,
       RANK()       OVER w AS rank,
       DENSE_RANK() OVER w AS dense_rank
FROM employees e
WHERE e.team_id = 1
WINDOW w AS (ORDER BY e.salary_cents DESC)
ORDER BY e.salary_cents DESC, e.full_name;

-- "Second-highest salary in each team": DENSE_RANK = 2 keeps every tied person.
WITH ranked AS (
  SELECT e.*, DENSE_RANK() OVER (PARTITION BY e.team_id ORDER BY e.salary_cents DESC) AS dr
  FROM employees e
)
SELECT t.team_name, r.full_name, r.salary_cents
FROM ranked r JOIN teams t ON t.team_id = r.team_id
WHERE r.dr = 2
ORDER BY t.team_name, r.full_name;
ROLLBACK;
