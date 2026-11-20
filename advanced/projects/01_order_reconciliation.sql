WITH order_totals AS (
 SELECT order_id,SUM(quantity*unit_price_cents) AS item_cents
 FROM order_items GROUP BY order_id
), payment_totals AS (
 SELECT order_id,SUM(amount_cents) AS paid_cents
 FROM payments GROUP BY order_id
)
SELECT o.order_id,o.status,
       COALESCE(i.item_cents,0) AS item_cents,
       COALESCE(p.paid_cents,0) AS payment_cents,
       CASE
        WHEN o.status <> 'paid' THEN 'NOT_PAID'
        WHEN p.paid_cents IS NULL THEN 'MISSING_PAYMENT'
        WHEN i.item_cents = p.paid_cents THEN 'MATCH'
        ELSE 'MISMATCH' END AS reconciliation
FROM orders o
LEFT JOIN order_totals i ON i.order_id=o.order_id
LEFT JOIN payment_totals p ON p.order_id=o.order_id
ORDER BY o.order_id;
-- The sample's paid orders all reconcile.
WITH items AS (
 SELECT order_id,SUM(quantity*unit_price_cents) AS total FROM order_items GROUP BY order_id
), paid AS (
 SELECT order_id,SUM(amount_cents) AS total FROM payments GROUP BY order_id
)
SELECT o.order_id FROM orders o
LEFT JOIN items i ON i.order_id=o.order_id
LEFT JOIN paid p ON p.order_id=o.order_id
WHERE o.status='paid' AND (i.total IS NULL OR p.total IS NULL OR i.total <> p.total);
