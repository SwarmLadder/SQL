-- PI02: Items vs payments without fan-out  (intermediate, query)
-- For paid orders, return order_id, items_cents (sum of quantity × unit_price_cents) and
-- paid_cents (sum of payment amounts, 0 if none), sorted by order_id. Joining items and
-- payments directly multiplies rows; aggregate each side first.
--
-- Write ONE read-only SELECT (or WITH ... SELECT) ending with a semicolon.
-- Check:  python tools/practice.py check PI02
-- Hints:  python tools/practice.py hint PI02 1

