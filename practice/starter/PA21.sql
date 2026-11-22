-- PA21: Index the pending-orders queue  (advanced, script)
-- An operations screen runs: SELECT order_id, ordered_at FROM orders WHERE status =
-- 'pending' ORDER BY ordered_at. Create one index so the plan searches an index and needs
-- no temporary sort.
--
-- Write a SQL script. End every statement with a semicolon.
-- Check:  python tools/practice.py check PA21
-- Hints:  python tools/practice.py hint PA21 1

