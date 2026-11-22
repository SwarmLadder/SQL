-- Worked example B3 · Finding duplicate customers
-- Examples from basics/worked_examples/03_find_duplicates.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/worked_examples/03_find_duplicates.sql
INSERT INTO customers (customer_id, full_name, email, city, joined_at) VALUES
  (20, 'Ana I.',     'ANA@example.test',     'Bucharest', '2026-08-01'),
  (21, 'Bogdan Pop', ' bogdan@example.test', 'Cluj-Napoca', '2026-08-02');

SELECT email, COUNT(*) AS copies
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

SELECT LOWER(TRIM(email)) AS normalised_email,
       COUNT(*) AS copies,
       MIN(customer_id) AS keep_id,
       MAX(customer_id) AS duplicate_id
FROM customers
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1
ORDER BY normalised_email;

SELECT c.customer_id, c.full_name, c.email, c.joined_at
FROM customers c
WHERE LOWER(TRIM(c.email)) IN (SELECT LOWER(TRIM(email)) FROM customers
                               GROUP BY LOWER(TRIM(email)) HAVING COUNT(*) > 1)
ORDER BY LOWER(TRIM(c.email)), c.customer_id;
