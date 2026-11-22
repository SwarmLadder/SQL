-- 07 · Text, dates, and grouped timelines
-- Examples from intermediate/lessons/07_dates_strings.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/lessons/07_dates_strings.sql
SELECT date('2026-03-12')                 AS d,
       strftime('%Y', '2026-03-12')        AS year,
       strftime('%m', '2026-03-12')        AS month,
       strftime('%d', '2026-03-12')        AS day,
       strftime('%w', '2026-03-12')        AS weekday_0_sunday,
       strftime('%j', '2026-03-12')        AS day_of_year,
       strftime('%Y-%m', '2026-03-12')     AS year_month;

SELECT date('2026-01-31', '+1 month')                 AS plus_one_month,
       date('2026-03-12', '+7 days')                   AS plus_week,
       date('2026-03-12', 'start of month')            AS month_start,
       date('2026-03-12', 'start of month', '+1 month', '-1 day') AS month_end,
       julianday('2026-03-12') - julianday('2026-02-10') AS days_between;

SELECT strftime('%Y', ordered_at) || '-Q' || ((CAST(strftime('%m', ordered_at) AS INTEGER) + 2) / 3) AS quarter,
       COUNT(*) AS orders,
       SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) AS paid
FROM orders
GROUP BY quarter
ORDER BY quarter;

SELECT CASE strftime('%w', ordered_at)
         WHEN '0' THEN 'Sun' WHEN '1' THEN 'Mon' WHEN '2' THEN 'Tue' WHEN '3' THEN 'Wed'
         WHEN '4' THEN 'Thu' WHEN '5' THEN 'Fri' ELSE 'Sat' END AS weekday,
       COUNT(*) AS orders
FROM orders
GROUP BY strftime('%w', ordered_at)
ORDER BY strftime('%w', ordered_at);

SELECT order_id, ordered_at
FROM orders
WHERE ordered_at >= '2026-06-01' AND ordered_at < date('2026-06-01', '+1 month')
ORDER BY ordered_at;

SELECT TRIM('  Cluj-Napoca ')                       AS trimmed,
       LOWER('ANA@Example.TEST')                     AS normalised_email,
       REPLACE('P-01', '-', '')                      AS no_dash,
       SUBSTR('ana@example.test', 1, INSTR('ana@example.test', '@') - 1) AS local_part,
       printf('%05d', 42)                            AS zero_padded;

SELECT o.order_id, group_concat(p.sku, ', ') AS skus
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
JOIN products p ON p.product_id = i.product_id
WHERE o.status = 'paid'
GROUP BY o.order_id
ORDER BY o.order_id;
