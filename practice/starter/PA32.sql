-- PA32: Status change log  (advanced, script)
-- Create status_log(order_id INTEGER, old_status TEXT, new_status TEXT) and a trigger that
-- logs every real change of orders.status (not no-op updates, not updates of other
-- columns). The checker runs three updates.
--
-- Write a SQL script. End every statement with a semicolon.
-- Check:  python tools/practice.py check PA32
-- Hints:  python tools/practice.py hint PA32 1

