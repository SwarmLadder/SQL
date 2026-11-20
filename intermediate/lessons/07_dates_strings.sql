SELECT order_id, ordered_at, strftime('%Y-%m', ordered_at) AS month
FROM orders ORDER BY ordered_at;
SELECT strftime('%Y-%m', ordered_at) AS month, COUNT(*) AS orders_count
FROM orders GROUP BY month ORDER BY month;
SELECT full_name, LOWER(email) AS normalized_email,
       SUBSTR(email, INSTR(email, '@') + 1) AS domain
FROM customers ORDER BY full_name;
SELECT order_id, ordered_at,
       date(ordered_at, '+7 days') AS expected_followup
FROM orders ORDER BY order_id LIMIT 5;
