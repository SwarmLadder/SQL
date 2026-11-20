-- Stable cursor pagination requires a total order and supporting index.
EXPLAIN QUERY PLAN
SELECT order_id,ordered_at FROM orders
WHERE customer_id=2 AND (ordered_at<'2026-05-14'
 OR (ordered_at='2026-05-14' AND order_id<108))
ORDER BY ordered_at DESC,order_id DESC LIMIT 5;
SELECT order_id,ordered_at FROM orders
WHERE customer_id=2 AND (ordered_at<'2026-05-14'
 OR (ordered_at='2026-05-14' AND order_id<108))
ORDER BY ordered_at DESC,order_id DESC LIMIT 5;
