SELECT customer_id, order_id,
  CAST(julianday(ordered_at) - julianday(LAG(ordered_at) OVER (PARTITION BY customer_id ORDER BY ordered_at, order_id)) AS INTEGER) AS days_since_previous
FROM orders
ORDER BY customer_id, ordered_at, order_id;
