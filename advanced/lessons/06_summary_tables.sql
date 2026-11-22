-- 06 · Summary tables and freshness
-- Examples from advanced/lessons/06_summary_tables.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/lessons/06_summary_tables.sql
CREATE VIEW live_category_revenue AS
SELECT p.category_id, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
FROM order_items i
JOIN orders o   ON o.order_id = i.order_id
JOIN products p ON p.product_id = i.product_id
WHERE o.status = 'paid'
GROUP BY p.category_id;

CREATE TABLE category_revenue_snapshot AS
SELECT * FROM live_category_revenue;

-- A new paid sale of a Keyboard (category 3) arrives.
INSERT INTO orders VALUES (600, 2, '2026-08-05', 'paid');
INSERT INTO order_items VALUES (600, 4, 1, 15900);

SELECT l.category_id, l.revenue_cents AS live_cents, s.revenue_cents AS snapshot_cents
FROM live_category_revenue l
JOIN category_revenue_snapshot s ON s.category_id = l.category_id
ORDER BY l.category_id;

CREATE TABLE customer_month_revenue (
  customer_id   INTEGER NOT NULL,
  month         TEXT    NOT NULL,
  revenue_cents INTEGER NOT NULL,
  refreshed_at  TEXT    NOT NULL,
  PRIMARY KEY (customer_id, month)
);

BEGIN;
DELETE FROM customer_month_revenue;
INSERT INTO customer_month_revenue (customer_id, month, revenue_cents, refreshed_at)
SELECT o.customer_id, strftime('%Y-%m', o.ordered_at), SUM(i.quantity * i.unit_price_cents), '2026-08-06T02:00'
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.customer_id, strftime('%Y-%m', o.ordered_at);
COMMIT;

SELECT customer_id, month, revenue_cents FROM customer_month_revenue ORDER BY month, customer_id;

INSERT INTO orders VALUES (601, 2, '2026-08-20', 'paid');
INSERT INTO order_items VALUES (601, 1, 2, 1200);

INSERT INTO customer_month_revenue (customer_id, month, revenue_cents, refreshed_at)
SELECT o.customer_id, strftime('%Y-%m', o.ordered_at), SUM(i.quantity * i.unit_price_cents), '2026-08-21T02:00'
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid' AND o.ordered_at >= '2026-08-01' AND o.ordered_at < '2026-09-01'
GROUP BY o.customer_id, strftime('%Y-%m', o.ordered_at)
ON CONFLICT(customer_id, month) DO UPDATE
  SET revenue_cents = excluded.revenue_cents,
      refreshed_at  = excluded.refreshed_at;

SELECT customer_id, month, revenue_cents, refreshed_at
FROM customer_month_revenue WHERE month = '2026-08';

SELECT MAX(refreshed_at) AS last_refresh FROM customer_month_revenue;

WITH live AS (
  SELECT o.customer_id, strftime('%Y-%m', o.ordered_at) AS month,
         SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM orders o JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.customer_id, month
)
SELECT COALESCE(l.customer_id, s.customer_id) AS customer_id,
       COALESCE(l.month, s.month) AS month,
       l.revenue_cents AS live_cents, s.revenue_cents AS summary_cents
FROM live l
FULL JOIN customer_month_revenue s ON s.customer_id = l.customer_id AND s.month = l.month
WHERE l.revenue_cents IS NOT s.revenue_cents;
