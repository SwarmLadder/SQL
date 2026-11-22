-- PA27: Withdraw only if covered  (advanced, script)
-- Create wallets(customer_id INTEGER PRIMARY KEY, balance_cents INTEGER NOT NULL CHECK
-- (balance_cents >= 0)) with (1, 1000) and (2, 200). Then withdraw 300 cents from each
-- wallet with conditional UPDATEs that succeed only when the balance covers it. The script
-- must not fail.
--
-- Write a SQL script. End every statement with a semicolon.
-- Check:  python tools/practice.py check PA27
-- Hints:  python tools/practice.py hint PA27 1

