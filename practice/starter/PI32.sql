-- PI32: Work queue order  (intermediate, query)
-- Return order_id, status for every order, sorted pending first, then paid, then
-- cancelled, and by order_id within each status.
--
-- Write ONE read-only SELECT (or WITH ... SELECT) ending with a semicolon.
-- Check:  python tools/practice.py check PI32
-- Hints:  python tools/practice.py hint PI32 1

