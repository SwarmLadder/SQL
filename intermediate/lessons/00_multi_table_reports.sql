-- 00 · Multi-table reporting
-- Examples from intermediate/lessons/00_multi_table_reports.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/lessons/00_multi_table_reports.sql
SELECT o.order_id,
       COUNT(*) AS joined_rows,
       SUM(i.quantity * i.unit_price_cents) AS items_cents,
       SUM(p.amount_cents) AS paid_cents
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
LEFT JOIN payments p ON p.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.order_id
ORDER BY o.order_id;

BEGIN;
INSERT INTO payments VALUES (90, 101, 1, 'cash', '2026-01-13');

SELECT o.order_id, i.product_id, p.payment_id, p.amount_cents
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
LEFT JOIN payments p ON p.order_id = o.order_id
WHERE o.order_id = 101
ORDER BY i.product_id, p.payment_id;

ROLLBACK;

SELECT o.order_id,
       items.items_cents,
       COALESCE(paid.paid_cents, 0) AS paid_cents
FROM orders o
JOIN (SELECT order_id, SUM(quantity * unit_price_cents) AS items_cents
      FROM order_items GROUP BY order_id) AS items
  ON items.order_id = o.order_id
LEFT JOIN (SELECT order_id, SUM(amount_cents) AS paid_cents
           FROM payments GROUP BY order_id) AS paid
  ON paid.order_id = o.order_id
WHERE o.status = 'paid'
ORDER BY o.order_id;

SELECT c.customer_id, c.full_name,
       COALESCE(ord.paid_orders, 0)  AS paid_orders,
       COALESCE(ord.items_cents, 0)  AS items_cents,
       COALESCE(pay.received_cents, 0) AS received_cents
FROM customers c
LEFT JOIN (
  SELECT o.customer_id, COUNT(DISTINCT o.order_id) AS paid_orders,
         SUM(i.quantity * i.unit_price_cents) AS items_cents
  FROM orders o JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.customer_id
) AS ord ON ord.customer_id = c.customer_id
LEFT JOIN (
  SELECT o.customer_id, SUM(p.amount_cents) AS received_cents
  FROM payments p JOIN orders o ON o.order_id = p.order_id
  GROUP BY o.customer_id
) AS pay ON pay.customer_id = c.customer_id
ORDER BY items_cents DESC, c.customer_id;

SELECT (SELECT SUM(amount_cents) FROM payments) AS source_payments,
       (SELECT SUM(paid_cents)
        FROM (SELECT order_id, SUM(amount_cents) AS paid_cents
              FROM payments GROUP BY order_id)) AS report_payments;
