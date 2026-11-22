# Worked example A2 · Remove duplicate events, then make them impossible

**Problem.** A retrying webhook stored `order_paid` for order 101 three times. Clean it up and stop it happening again.

**Run:** `python tools/run_sql.py advanced/worked_examples/02_dedupe_events.sql` (everything is rolled back at the end)

## 1. Define "duplicate" precisely

`event_id` and `created_at` differ between copies, so they can't identify the business event. Same `event_type` **and** same `payload_json → order_id` can. Write that definition down; it becomes both the `PARTITION BY` and the unique index.

## 2. Find, then delete with exactly one survivor

```sql
ROW_NUMBER() OVER (PARTITION BY event_type, json_extract(payload_json, '$.order_id')
                   ORDER BY created_at, event_id) AS rn
```

`rn = 1` is the earliest copy; delete `rn > 1`. `ROW_NUMBER` (not `RANK`) guarantees a single survivor even if two copies share a timestamp, because `event_id` breaks the tie.

## 3. Prevent recurrence in the database

```sql
CREATE UNIQUE INDEX uq_audit_event ON audit_events(event_type, json_extract(payload_json, '$.order_id'));
```

An expression index enforces the rule for every writer, including ones you didn't write. Application-level "check, then insert" has a race between the check and the insert.

The retry then uses `INSERT OR IGNORE` (or `ON CONFLICT DO NOTHING`) so a duplicate delivery is a harmless no-op.

## 4. Order of operations in production

1. Deploy code that tolerates the unique violation.
2. Delete existing duplicates. The index can't be created while they exist.
3. Create the index. On a large table, check how long it locks writes on your database engine.

**Practise next:** [PA08](../../practice/starter/PA08.sql), [PA10](../../practice/starter/PA10.sql) and the backend lab's idempotency recipes.
