SELECT strftime('%Y', ordered_at) || '-Q' || ((CAST(strftime('%m', ordered_at) AS INTEGER) + 2) / 3) AS quarter,
  COUNT(*) AS orders
FROM orders
GROUP BY quarter
ORDER BY quarter;
