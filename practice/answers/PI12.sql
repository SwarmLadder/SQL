SELECT customer_id, order_id, ordered_at,
  LAG(ordered_at) OVER (PARTITION BY customer_id ORDER BY ordered_at, order_id) AS previous_ordered_at
FROM orders
ORDER BY customer_id, ordered_at, order_id;
