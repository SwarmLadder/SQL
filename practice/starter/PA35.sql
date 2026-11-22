-- PA35: At most one default address  (advanced, script)
-- Create addresses(address_id INTEGER PRIMARY KEY, customer_id INTEGER NOT NULL,
-- is_default INTEGER NOT NULL DEFAULT 0 CHECK (is_default IN (0, 1))) and an index that
-- allows any number of non-default addresses per customer but at most one default. The
-- checker tries four inserts.
--
-- Write a SQL script. End every statement with a semicolon.
-- Check:  python tools/practice.py check PA35
-- Hints:  python tools/practice.py hint PA35 1

