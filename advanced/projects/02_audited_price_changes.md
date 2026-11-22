# Audited Price Changes

**Scenario.** Pricing changes must be traceable: every real change recorded, risky changes reversible, and the limits of the audit documented for the security review.

**You'll use:** Advanced lessons [03](../lessons/03_transactions_savepoints.md) and [05](../lessons/05_triggers_audit.md).

Work in your own file (for example `my_02_audited_price_changes.sql` in this folder) and run it with `python tools/run_sql.py`. Every run starts from a fresh sample database. The reference solution is [`02_audited_price_changes.sql`](02_audited_price_changes.sql); open it only after your own attempt.

## Tickets

### Ticket 1 · Audit trigger

Record every real change of `unit_price_cents` with old and new value.

**Acceptance**

- No row for an update that sets the same price.
- No row for updates of other columns.

### Ticket 2 · Reversible changes

Apply a batch of price changes, undo part of it with a savepoint, commit the rest.

**Acceptance**

- The audit table contains only the changes that were committed.
- Final prices are shown and explained.

### Ticket 3 · Limits

Write five sentences on what this audit cannot prove (identity, tampering, retention).

**Acceptance**

- Each limitation names a concrete mitigation.

## Stretch goals

1. Audit changes of `active` in a second table.
2. Report the latest price change per product with a window function.
3. Reject price changes above 50% with a `BEFORE UPDATE` trigger.

## Review rubric

| Dimension | Points | Evidence |
|---|---:|---|
| Correctness | 40 | Every ticket's acceptance criteria hold on a fresh database |
| Edge cases | 20 | You state and test at least one edge case per ticket (empty group, NULL, tie, unmatched row) |
| Query design | 15 | Right grain, right join type, no fan-out, deterministic ordering |
| Readability | 15 | One query per ticket, a comment with the question it answers, aliases that read well |
| Verification | 10 | At least one independent cross-check of a total |

**Done when** your file runs top to bottom with `python tools/run_sql.py <your file>`, every acceptance criterion is met, and you can explain each query out loud. Then compare with the reference solution and note one thing it does differently.
