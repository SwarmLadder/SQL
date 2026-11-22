-- 04 · CASE and conditional aggregation
-- Examples from intermediate/lessons/04_case_conditional.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/lessons/04_case_conditional.sql
SELECT sku, unit_price_cents,
       CASE
         WHEN unit_price_cents < 1000  THEN 'budget'
         WHEN unit_price_cents < 10000 THEN 'standard'
         ELSE 'premium'
       END AS price_band
FROM products
ORDER BY unit_price_cents;

SELECT order_id, status,
       CASE status WHEN 'paid' THEN 'done'
                   WHEN 'pending' THEN 'waiting'
                   ELSE 'closed' END AS stage
FROM orders
ORDER BY CASE status WHEN 'pending' THEN 0 WHEN 'paid' THEN 1 ELSE 2 END,
         order_id;

SELECT SUBSTR(ordered_at, 1, 7) AS month,
       COUNT(*) AS orders,
       SUM(CASE WHEN status = 'paid'      THEN 1 ELSE 0 END) AS paid,
       SUM(CASE WHEN status = 'pending'   THEN 1 ELSE 0 END) AS pending,
       SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled
FROM orders
GROUP BY month
ORDER BY month;

SELECT SUBSTR(paid_at, 1, 7) AS month,
       SUM(CASE WHEN method = 'card'     THEN amount_cents ELSE 0 END) AS card_cents,
       SUM(CASE WHEN method = 'transfer' THEN amount_cents ELSE 0 END) AS transfer_cents,
       SUM(CASE WHEN method = 'cash'     THEN amount_cents ELSE 0 END) AS cash_cents,
       SUM(amount_cents) AS total_cents
FROM payments
GROUP BY month
ORDER BY month;

SELECT full_name,
       CASE WHEN manager_id IS NULL THEN 'lead' ELSE 'member' END AS role
FROM employees
ORDER BY role, full_name;
