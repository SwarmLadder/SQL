# Worked example I6 · A running balance from two kinds of events

**Problem.** Finance tracks money in (payments) and money out (refunds) in separate tables, and wants a single ledger with a **running balance** after every movement.

**Run:** `python tools/run_sql.py intermediate/worked_examples/06_running_balance.sql`

## 1. Plan

1. Create the refunds (the sample has none):

```sql
CREATE TABLE refunds (
  refund_id INTEGER PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(order_id),
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  refunded_at TEXT NOT NULL
);
INSERT INTO refunds VALUES (1, 103, 6500, '2026-03-20'), (2, 110, 250, '2026-06-25');
```

<!-- result -->
*Rows changed: 2*
<!-- /result -->

2. Stack both tables into one movement list with `UNION ALL`, refunds as **negative** amounts.
3. Run `SUM() OVER (ORDER BY date, tie-breaker)`.

## 2. Tempting attempt: join them

```sql
SELECT p.paid_at, p.amount_cents, r.amount_cents AS refund_cents
FROM payments p
LEFT JOIN refunds r ON r.order_id = p.order_id
ORDER BY p.paid_at;
```

<!-- result -->
| paid_at | amount_cents | refund_cents |
|---|---|---|
| 2026-01-12 | 3150 | *NULL* |
| 2026-02-05 | 5400 | *NULL* |
| 2026-03-02 | 22400 | 6500 |
| 2026-04-06 | 19600 | *NULL* |
| 2026-05-04 | 10100 | *NULL* |
| 2026-06-02 | 11350 | *NULL* |
| 2026-06-21 | 16150 | 250 |
| 2026-07-08 | 13800 | *NULL* |
<!-- /result -->

A join puts the refund *next to* the payment, on the payment's date. It can't produce a time-ordered list of movements, and a second refund for the same order would duplicate the payment row.

## 3. Fix: stack, sign, accumulate

```sql
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
```

<!-- result -->
| happened_at | kind | order_id | delta_cents | balance_cents |
|---|---|---|---|---|
| 2026-01-12 | payment | 101 | 3150 | 3150 |
| 2026-02-05 | payment | 102 | 5400 | 8550 |
| 2026-03-02 | payment | 103 | 22400 | 30950 |
| 2026-03-20 | refund | 103 | -6500 | 24450 |
| 2026-04-06 | payment | 105 | 19600 | 44050 |
| 2026-05-04 | payment | 107 | 10100 | 54150 |
| 2026-06-02 | payment | 109 | 11350 | 65500 |
| 2026-06-21 | payment | 110 | 16150 | 81650 |
| 2026-06-25 | refund | 110 | -250 | 81400 |
| 2026-07-08 | payment | 111 | 13800 | 95200 |
<!-- /result -->

- Columns line up **by position** in a `UNION ALL`, so both parts list the same columns in the same order.
- The window's `ORDER BY` is unique (`happened_at, kind, ref`), so two movements on the same day never share a balance.

## 4. Test it

```sql
SELECT (SELECT SUM(amount_cents) FROM payments) - (SELECT SUM(amount_cents) FROM refunds) AS expected_final_balance;
```

<!-- result -->
| expected_final_balance |
|---|
| 95200 |
<!-- /result -->

The last `balance_cents` in the ledger must equal this independent total (95 200). Add `PARTITION BY order_id` to the window to get a balance per order instead, which shows that order 103 is now partly refunded.

**Practise next:** [PI37](../../practice/starter/PI37.sql), [PI43](../../practice/starter/PI43.sql).
