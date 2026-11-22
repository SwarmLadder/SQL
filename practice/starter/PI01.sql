-- PI01: Customer lifetime totals  (intermediate, query)
-- Using a CTE, return customer_id, full_name, lifetime_cents (sum of
-- payments.amount_cents) for customers with at least one payment. Sort by lifetime_cents
-- descending, then customer_id.
--
-- Write ONE read-only SELECT (or WITH ... SELECT) ending with a semicolon.
-- Check:  python tools/practice.py check PI01
-- Hints:  python tools/practice.py hint PI01 1

