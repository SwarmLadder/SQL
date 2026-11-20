SELECT order_id,ordered_at FROM orders WHERE ordered_at>'2026-04-06' OR (ordered_at='2026-04-06' AND order_id>105) ORDER BY ordered_at,order_id LIMIT 5;
