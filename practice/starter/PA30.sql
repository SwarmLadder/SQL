-- PA30: Keep the latest timestamp  (advanced, script)
-- Create last_seen(product_id INTEGER PRIMARY KEY, seen_at TEXT NOT NULL). Record events
-- (1, '2026-05-01'), (1, '2026-03-01'), (2, '2026-04-01') in that order with upserts so
-- each product keeps its latest seen_at even when events arrive out of order.
--
-- Write a SQL script. End every statement with a semicolon.
-- Check:  python tools/practice.py check PA30
-- Hints:  python tools/practice.py hint PA30 1

