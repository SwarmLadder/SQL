-- 03 · Types and expressions
-- Examples from basics/lessons/03_expressions.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/lessons/03_expressions.sql
SELECT order_id, product_id, quantity, unit_price_cents,
       quantity * unit_price_cents AS line_cents
FROM order_items
WHERE order_id IN (101, 105);

SELECT 7 / 2      AS integer_division,
       7 / 2.0    AS real_division,
       7 % 2      AS remainder,
       0.1 + 0.2  AS float_sum;

SELECT sku,
       unit_price_cents,
       unit_price_cents * 90 / 100 AS ten_pct_off_cents,
       printf('%.2f', unit_price_cents / 100.0) AS price_eur
FROM products
ORDER BY sku
LIMIT 4;

SELECT UPPER(full_name) AS name_upper,
       SUBSTR(email, INSTR(email, '@') + 1) AS email_domain,
       SUBSTR(joined_at, 1, 7) AS joined_month,
       LENGTH(full_name) AS name_length
FROM customers
ORDER BY customer_id
LIMIT 4;

SELECT typeof(42)            AS int_type,
       typeof(4.2)           AS real_type,
       typeof('42')          AS text_type,
       typeof(NULL)          AS null_type,
       CAST('42' AS INTEGER) + 1 AS cast_sum,
       '10' < '9'            AS text_compare,
       10 < 9                AS number_compare;
