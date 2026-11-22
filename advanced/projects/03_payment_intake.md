# Idempotent Payment Intake

**Scenario.** The payment provider calls a webhook for every successful payment and retries deliveries it isn't sure about. Design the database side so retries are harmless, conflicting deliveries raise an alert, and the books always reconcile.

**You'll use:** Advanced lessons [00](../lessons/00_indexes_explain.md), [03](../lessons/03_transactions_savepoints.md), [04](../lessons/04_upsert_idempotency.md), [05](../lessons/05_triggers_audit.md), [09](../lessons/09_advanced_capstone.md).

Work in your own file (for example `my_03_payment_intake.sql` in this folder) and run it with `python tools/run_sql.py`. Every run starts from a fresh sample database. The reference solution is [`03_payment_intake.sql`](03_payment_intake.sql); open it only after your own attempt.

## Tickets

### Ticket 1 · Event table

`payment_events` keyed by the provider's event id, with order, amount, payload hash and received time.

**Acceptance**

- The event id is the primary key.
- Amount must be positive; order must exist.

### Ticket 2 · No overpayment

A rule in the database that rejects a payment exceeding what is still owed on the order.

**Acceptance**

- Demonstrate one accepted and one rejected payment.

### Ticket 3 · Atomic intake

Record event, payment and order status change in one transaction.

**Acceptance**

- A retried delivery with the same event id inserts nothing (`changes()` = 0).
- Nothing is half-recorded if any statement fails.

### Ticket 4 · Triage incoming deliveries

Classify a batch of deliveries as process / duplicate / conflict.

**Acceptance**

- Same id + same hash → duplicate; same id + different hash → conflict.

### Ticket 5 · Reconcile

After intake, list paid orders whose payments don't equal their items, and non-paid orders that were paid in full.

**Acceptance**

- Empty after the sample intake.

### Ticket 6 · Fast lookup

Show the plan for the per-delivery lookup.

**Acceptance**

- It searches an index; no table scan.

## Stretch goals

1. Store the HTTP response with the event so retries return it byte-for-byte.
2. Add an expiry policy for old events and a query that finds candidates to delete.
3. Write the same design for PostgreSQL using `INSERT … ON CONFLICT` and `SELECT … FOR UPDATE` (see the PostgreSQL labs).

## Review rubric

| Dimension | Points | Evidence |
|---|---:|---|
| Correctness | 40 | Every ticket's acceptance criteria hold on a fresh database |
| Edge cases | 20 | You state and test at least one edge case per ticket (empty group, NULL, tie, unmatched row) |
| Query design | 15 | Right grain, right join type, no fan-out, deterministic ordering |
| Readability | 15 | One query per ticket, a comment with the question it answers, aliases that read well |
| Verification | 10 | At least one independent cross-check of a total |

**Done when** your file runs top to bottom with `python tools/run_sql.py <your file>`, every acceptance criterion is met, and you can explain each query out loud. Then compare with the reference solution and note one thing it does differently.
