# Order and Payment Reconciliation

**Scenario.** Finance closes the month only when every paid order has been paid exactly its value. Build the reconciliation they run, and make it impossible to miss a problem.

**You'll use:** Advanced lessons [01](../lessons/01_query_rewrites.md), [08](../lessons/08_null_semantics.md), [09](../lessons/09_advanced_capstone.md).

Work in your own file (for example `my_01_order_reconciliation.sql` in this folder) and run it with `python tools/run_sql.py`. Every run starts from a fresh sample database. The reference solution is [`01_order_reconciliation.sql`](01_order_reconciliation.sql); open it only after your own attempt.

## Tickets

### Ticket 1 · Reconciliation

One row per order with item total, payment total and a status: NOT_PAID, MISSING_PAYMENT, MATCH or MISMATCH.

**Acceptance**

- Items and payments are pre-aggregated separately (no fan-out).
- Orders without payments are kept, not dropped.

### Ticket 2 · Exceptions only

A query returning only the paid orders that don't reconcile.

**Acceptance**

- Empty on the sample data.
- Returns the right orders after you break the data inside a transaction (short payment, missing payment).

## Stretch goals

1. Counts per reconciliation status.
2. Flag payments recorded on orders that aren't paid.
3. Describe a transactional workflow (or trigger) that prevents mismatches being written at all.

## Review rubric

| Dimension | Points | Evidence |
|---|---:|---|
| Correctness | 40 | Every ticket's acceptance criteria hold on a fresh database |
| Edge cases | 20 | You state and test at least one edge case per ticket (empty group, NULL, tie, unmatched row) |
| Query design | 15 | Right grain, right join type, no fan-out, deterministic ordering |
| Readability | 15 | One query per ticket, a comment with the question it answers, aliases that read well |
| Verification | 10 | At least one independent cross-check of a total |

**Done when** your file runs top to bottom with `python tools/run_sql.py <your file>`, every acceptance criterion is met, and you can explain each query out loud. Then compare with the reference solution and note one thing it does differently.
