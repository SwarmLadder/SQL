SELECT CAST(strftime('%w', ordered_at) AS INTEGER) AS weekday, COUNT(*) AS orders
FROM orders
GROUP BY weekday
ORDER BY weekday;
