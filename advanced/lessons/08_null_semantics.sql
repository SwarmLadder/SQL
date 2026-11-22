-- 08 · NULL, anti-joins, and query correctness
-- Examples from advanced/lessons/08_null_semantics.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/lessons/08_null_semantics.sql
SELECT NULL = NULL      AS eq,
       NULL IS NULL     AS is_null,
       NULL IS NOT 1    AS null_safe_diff,
       (NULL AND 0)     AS and_false,
       (NULL OR 1)      AS or_true,
       COALESCE(NULL, 'fallback') AS coalesce_value,
       NULLIF(5, 5)     AS nullif_value;

SELECT COUNT(*) AS not_in_rows
FROM employees
WHERE employee_id NOT IN (SELECT manager_id FROM employees);

SELECT COUNT(*) AS not_exists_rows
FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM employees r WHERE r.manager_id = e.employee_id);

SELECT (SELECT COUNT(*) FROM employees WHERE manager_id <> 1)        AS with_not_equal,
       (SELECT COUNT(*) FROM employees WHERE manager_id IS NOT 1)    AS null_safe;

BEGIN;
CREATE TABLE ratings (product_id INTEGER, stars INTEGER);
INSERT INTO ratings VALUES (1, 5), (1, NULL), (1, 3), (2, NULL);

SELECT product_id,
       COUNT(*)      AS rows_total,
       COUNT(stars)  AS rated,
       AVG(stars)    AS avg_of_rated,
       SUM(stars)    AS sum_stars,
       AVG(COALESCE(stars, 0)) AS avg_treating_null_as_zero
FROM ratings
GROUP BY product_id
ORDER BY product_id;

ROLLBACK;

SELECT manager_id, COUNT(*) AS employees
FROM employees
GROUP BY manager_id
ORDER BY manager_id;
