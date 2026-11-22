-- Worked example A1: from SCAN to SEARCH for "latest pending orders".
-- The query an operations screen runs every few seconds:
--   SELECT order_id, customer_id, ordered_at FROM orders
--   WHERE status = 'pending' ORDER BY ordered_at DESC LIMIT 20;

-- Before: a full table scan plus a temporary sort.
EXPLAIN QUERY PLAN
SELECT order_id, customer_id, ordered_at FROM orders
WHERE status = 'pending' ORDER BY ordered_at DESC LIMIT 20;

-- Equality column first, sort column second. SQLite can walk the index backwards for DESC.
CREATE INDEX idx_orders_status_date ON orders(status, ordered_at);

-- After: SEARCH using the index, no TEMP B-TREE.
EXPLAIN QUERY PLAN
SELECT order_id, customer_id, ordered_at FROM orders
WHERE status = 'pending' ORDER BY ordered_at DESC LIMIT 20;

-- The result itself must not change. Compare it with the plan-free reading.
SELECT order_id, customer_id, ordered_at FROM orders
WHERE status = 'pending' ORDER BY ordered_at DESC LIMIT 20;
