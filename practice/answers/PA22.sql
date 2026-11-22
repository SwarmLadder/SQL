SELECT order_id, ordered_at
FROM orders
WHERE (ordered_at, order_id) > ('2026-03-12', 104)
ORDER BY ordered_at, order_id
LIMIT 4;
