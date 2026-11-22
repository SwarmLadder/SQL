-- Worked example I6 · A running balance from two kinds of events
-- Examples from intermediate/worked_examples/06_running_balance.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py intermediate/worked_examples/06_running_balance.sql
CREATE TABLE refunds (
  refund_id INTEGER PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(order_id),
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  refunded_at TEXT NOT NULL
);
INSERT INTO refunds VALUES (1, 103, 6500, '2026-03-20'), (2, 110, 250, '2026-06-25');

SELECT p.paid_at, p.amount_cents, r.amount_cents AS refund_cents
FROM payments p
LEFT JOIN refunds r ON r.order_id = p.order_id
ORDER BY p.paid_at;

WITH movements AS (
  SELECT paid_at AS happened_at, 'payment' AS kind, payment_id AS ref, order_id, amount_cents AS delta_cents
  FROM payments
  UNION ALL
  SELECT refunded_at, 'refund', refund_id, order_id, -amount_cents
  FROM refunds
)
SELECT happened_at, kind, order_id, delta_cents,
       SUM(delta_cents) OVER (ORDER BY happened_at, kind, ref
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS balance_cents
FROM movements
ORDER BY happened_at, kind, ref;

SELECT (SELECT SUM(amount_cents) FROM payments) - (SELECT SUM(amount_cents) FROM refunds) AS expected_final_balance;
