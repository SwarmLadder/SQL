-- 09 · Advanced reporting capstone
-- Examples from advanced/lessons/09_advanced_capstone.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/lessons/09_advanced_capstone.sql
WITH items AS (
  SELECT order_id, SUM(quantity * unit_price_cents) AS item_cents
  FROM order_items GROUP BY order_id
), received AS (
  SELECT order_id, SUM(amount_cents) AS received_cents, COUNT(*) AS payments
  FROM payments GROUP BY order_id
)
SELECT o.order_id, o.status,
       COALESCE(i.item_cents, 0)     AS item_cents,
       COALESCE(r.received_cents, 0) AS received_cents,
       CASE
         WHEN o.status = 'paid' AND r.order_id IS NULL                 THEN 'missing_payment'
         WHEN o.status = 'paid' AND r.received_cents <> i.item_cents   THEN 'amount_mismatch'
         WHEN o.status = 'paid'                                         THEN 'ok'
         WHEN r.order_id IS NOT NULL                                    THEN 'unexpected_payment'
         ELSE 'not_due'
       END AS flag
FROM orders o
LEFT JOIN items i    ON i.order_id = o.order_id
LEFT JOIN received r ON r.order_id = o.order_id
ORDER BY o.order_id;

BEGIN;
UPDATE payments SET amount_cents = amount_cents - 100 WHERE payment_id = 1;      -- short payment
INSERT INTO payments VALUES (99, 104, 5500, 'card', '2026-03-12');               -- pending order paid
DELETE FROM payments WHERE payment_id = 8;                                         -- paid order, no payment

WITH items AS (
  SELECT order_id, SUM(quantity * unit_price_cents) AS item_cents FROM order_items GROUP BY order_id
), received AS (
  SELECT order_id, SUM(amount_cents) AS received_cents FROM payments GROUP BY order_id
)
SELECT o.order_id, o.status, i.item_cents, COALESCE(r.received_cents, 0) AS received_cents,
       CASE
         WHEN o.status = 'paid' AND r.order_id IS NULL               THEN 'missing_payment'
         WHEN o.status = 'paid' AND r.received_cents <> i.item_cents THEN 'amount_mismatch'
         WHEN o.status = 'paid'                                       THEN 'ok'
         WHEN r.order_id IS NOT NULL                                  THEN 'unexpected_payment'
         ELSE 'not_due'
       END AS flag
FROM orders o
LEFT JOIN items i    ON i.order_id = o.order_id
LEFT JOIN received r ON r.order_id = o.order_id
WHERE o.order_id IN (101, 104, 111)
ORDER BY o.order_id;

ROLLBACK;

WITH category_revenue AS (
  SELECT c.category_name, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM order_items i
  JOIN orders o     ON o.order_id = i.order_id AND o.status = 'paid'
  JOIN products p   ON p.product_id = i.product_id
  JOIN categories c ON c.category_id = p.category_id
  GROUP BY c.category_id, c.category_name
)
SELECT category_name, revenue_cents,
       ROUND(100.0 * revenue_cents / SUM(revenue_cents) OVER (), 1) AS share_pct,
       SUM(revenue_cents) OVER (ORDER BY revenue_cents DESC, category_name) AS cumulative_cents
FROM category_revenue
ORDER BY revenue_cents DESC, category_name;

WITH customer_revenue AS (
  SELECT o.customer_id, SUM(i.quantity * i.unit_price_cents) AS revenue_cents,
         COUNT(DISTINCT o.order_id) AS paid_orders
  FROM orders o JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.customer_id
)
SELECT DENSE_RANK() OVER (ORDER BY r.revenue_cents DESC) AS rank,
       c.full_name, c.city, r.paid_orders, r.revenue_cents
FROM customer_revenue r
JOIN customers c ON c.customer_id = r.customer_id
ORDER BY rank, c.customer_id
LIMIT 5;

EXPLAIN QUERY PLAN
SELECT order_id, SUM(amount_cents) FROM payments WHERE order_id = 101;

CREATE INDEX idx_payments_order ON payments(order_id, amount_cents);

EXPLAIN QUERY PLAN
SELECT order_id, SUM(amount_cents) FROM payments WHERE order_id = 101;

-- (a) Revenue by category adds up to total paid item value.
SELECT 'category total' AS check_name
WHERE (SELECT SUM(i.quantity * i.unit_price_cents) FROM order_items i JOIN orders o ON o.order_id = i.order_id WHERE o.status = 'paid')
   <> (SELECT SUM(i.quantity * i.unit_price_cents) FROM order_items i
       JOIN orders o ON o.order_id = i.order_id AND o.status = 'paid'
       JOIN products p ON p.product_id = i.product_id
       JOIN categories c ON c.category_id = p.category_id)
UNION ALL
-- (b) Every order appears exactly once in the reconciliation.
SELECT 'reconciliation rows'
WHERE (SELECT COUNT(*) FROM orders)
   <> (SELECT COUNT(*) FROM orders o LEFT JOIN (SELECT order_id FROM payments GROUP BY order_id) r ON r.order_id = o.order_id)
UNION ALL
-- (c) Received money equals the sum of payments (nothing lost or duplicated).
SELECT 'payments total'
WHERE (SELECT SUM(amount_cents) FROM payments)
   <> (SELECT SUM(received_cents) FROM (SELECT order_id, SUM(amount_cents) AS received_cents FROM payments GROUP BY order_id));
