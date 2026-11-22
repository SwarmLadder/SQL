-- PI21: Lines and payments per order  (intermediate, query)
-- For paid orders, return order_id, line_count (number of order lines) and payment_count
-- (number of payments, 0 if none), sorted by order_id. Count each table separately so
-- neither count is multiplied by the other.
--
-- Write ONE read-only SELECT (or WITH ... SELECT) ending with a semicolon.
-- Check:  python tools/practice.py check PI21
-- Hints:  python tools/practice.py hint PI21 1

