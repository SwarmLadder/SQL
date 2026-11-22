-- PI37: Running spend per customer  (intermediate, query)
-- For paid orders, return customer_id, order_id, total_cents (the order's line total) and
-- running_cents (the customer's cumulative paid total up to and including this order, by
-- ordered_at then order_id). Sort by customer_id, ordered_at, order_id.
--
-- Write ONE read-only SELECT (or WITH ... SELECT) ending with a semicolon.
-- Check:  python tools/practice.py check PI37
-- Hints:  python tools/practice.py hint PI37 1

