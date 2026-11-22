-- PA01: Index for a hot query  (advanced, script)
-- The payments screen runs: SELECT payment_id, amount_cents FROM payments WHERE method =
-- 'card' ORDER BY paid_at. Create one index so SQLite can both filter and sort through it
-- (no full scan, no temporary sort). Check your plan with EXPLAIN QUERY PLAN first.
--
-- Write a SQL script. End every statement with a semicolon.
-- Check:  python tools/practice.py check PA01
-- Hints:  python tools/practice.py hint PA01 1

