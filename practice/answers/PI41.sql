SELECT order_id, ordered_at
FROM orders
WHERE ordered_at >= '2026-06-01' AND ordered_at < '2026-07-01'
ORDER BY ordered_at, order_id;
