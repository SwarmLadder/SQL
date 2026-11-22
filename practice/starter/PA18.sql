-- PA18: Order-to-payment reconciliation  (advanced, query)
-- For every order return order_id, status, items_cents, paid_cents (0 if none) and flag:
-- 'missing_payment' (paid, no payment), 'mismatch' (paid, amounts differ), 'ok' (paid,
-- amounts match), 'unexpected_payment' (not paid but has a payment), 'not_due' otherwise.
-- Sort by order_id.
--
-- Write ONE read-only SELECT (or WITH ... SELECT) ending with a semicolon.
-- Check:  python tools/practice.py check PA18
-- Hints:  python tools/practice.py hint PA18 1

