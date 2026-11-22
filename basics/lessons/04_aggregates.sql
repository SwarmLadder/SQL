-- 04 · COUNT, SUM, MIN, MAX, AVG
-- Examples from basics/lessons/04_aggregates.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/lessons/04_aggregates.sql
SELECT COUNT(*)              AS line_count,
       SUM(quantity)         AS units,
       MIN(unit_price_cents) AS cheapest_line_price,
       MAX(unit_price_cents) AS dearest_line_price,
       AVG(quantity)         AS avg_quantity
FROM order_items;

SELECT MIN(ordered_at) AS first_order, MAX(ordered_at) AS last_order
FROM orders;

SELECT COUNT(*) AS paid_orders
FROM orders
WHERE status = 'paid';

SELECT SUM(amount_cents) AS card_cents
FROM payments
WHERE method = 'card';

SELECT COUNT(*)                   AS employees,
       COUNT(manager_id)          AS with_manager,
       COUNT(DISTINCT manager_id) AS distinct_managers
FROM employees;

SELECT COUNT(*)          AS rows_found,
       SUM(amount_cents) AS total,
       COALESCE(SUM(amount_cents), 0) AS total_or_zero
FROM payments
WHERE method = 'cash' AND amount_cents > 1000000;

SELECT AVG(unit_price_cents)           AS avg_price_cents,
       ROUND(AVG(unit_price_cents))    AS avg_price_rounded,
       ROUND(AVG(unit_price_cents), 1) AS avg_price_one_decimal
FROM products;
