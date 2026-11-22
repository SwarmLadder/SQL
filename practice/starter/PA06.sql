-- PA06: Reporting paths with a depth limit  (advanced, query)
-- Return employee_id and path, where path is the chain of names from the top manager down,
-- joined with ' > ' (for example 'Ada > Ben'). Stop at depth 1 (top managers and their
-- direct reports only), and guard against cycles by never revisiting a name already in the
-- path. Sort by path.
--
-- Write ONE read-only SELECT (or WITH ... SELECT) ending with a semicolon.
-- Check:  python tools/practice.py check PA06
-- Hints:  python tools/practice.py hint PA06 1

