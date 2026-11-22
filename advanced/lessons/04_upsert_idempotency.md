# 04 · UPSERT and idempotency keys

> **You will learn** to insert-or-update atomically with `INSERT … ON CONFLICT`, the difference between `DO NOTHING`, `DO UPDATE` and `INSERT OR REPLACE`, to make API requests safe to retry with **idempotency keys**, and why a retry policy must compare the request payload.
> **Time:** about 60 minutes · **Before this:** [03 · Atomic changes and savepoints](03_transactions_savepoints.md)

Networks fail *after* the server did the work but *before* the client heard back. The client retries. Without care, a retry charges the card twice or creates two orders. A database **unique key** plus the right conflict policy makes repeating a request harmless.

**Run the whole lesson:** `python tools/run_sql.py advanced/lessons/04_upsert_idempotency.sql`

## 1. Check-then-insert is a race

```text
Request A: SELECT … WHERE key = 'k1'  → none     Request B: SELECT … WHERE key = 'k1' → none
Request A: INSERT 'k1'                            Request B: INSERT 'k1'   → duplicate!
```

The only reliable guard is a **unique constraint**: the database lets exactly one insert win. Everything in this lesson builds on that.

## 2. ON CONFLICT DO NOTHING

```sql
CREATE TABLE newsletter (email TEXT PRIMARY KEY, subscribed_at TEXT NOT NULL);

INSERT INTO newsletter VALUES ('ana@example.test', '2026-01-05')
ON CONFLICT(email) DO NOTHING;
INSERT INTO newsletter VALUES ('ana@example.test', '2026-02-01')
ON CONFLICT(email) DO NOTHING;
SELECT changes() AS second_insert_changed;

SELECT * FROM newsletter;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 0*

| second_insert_changed |
|---|
| 0 |

| email | subscribed_at |
|---|---|
| ana@example.test | 2026-01-05 |
<!-- /result -->

The second insert is silently skipped (`changes()` = 0). Use it when "already there" is a success: subscriptions, tags, seen-event markers. `INSERT OR IGNORE` is SQLite's older spelling, but it also ignores `NOT NULL` and `CHECK` violations, which is usually not what you want.

## 3. ON CONFLICT DO UPDATE (UPSERT)

Insert a new row, or update the existing one, in **one atomic statement**. `excluded` refers to the row you tried to insert:

```sql
CREATE TABLE product_stats (
  product_id INTEGER PRIMARY KEY,
  units_sold INTEGER NOT NULL,
  last_sold_at TEXT NOT NULL
);

INSERT INTO product_stats VALUES (1, 2, '2026-01-12')
ON CONFLICT(product_id) DO UPDATE
  SET units_sold = units_sold + excluded.units_sold,
      last_sold_at = max(last_sold_at, excluded.last_sold_at);

INSERT INTO product_stats VALUES (1, 3, '2026-05-04')
ON CONFLICT(product_id) DO UPDATE
  SET units_sold = units_sold + excluded.units_sold,
      last_sold_at = max(last_sold_at, excluded.last_sold_at);

SELECT * FROM product_stats;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*

| product_id | units_sold | last_sold_at |
|---|---|---|
| 1 | 5 | 2026-05-04 |
<!-- /result -->

- `units_sold` (unqualified) is the **existing** row's value; `excluded.units_sold` is the **new** one.
- `max(last_sold_at, excluded.last_sold_at)` keeps the latest date even if events arrive out of order.
- A `WHERE` after `DO UPDATE SET …` updates only when a condition holds, which is useful for "only if newer".

**Careful:** a counter upsert is **not** idempotent. Replaying the same event adds the units again. Combine it with an event-ID check (section 5).

## 4. INSERT OR REPLACE is not an update

`INSERT OR REPLACE` (and MySQL's `REPLACE`) **deletes** the old row and inserts a new one. Columns you didn't supply are reset to their defaults, and in other tables `ON DELETE` actions fire:

```sql
CREATE TABLE profiles (customer_id INTEGER PRIMARY KEY, nickname TEXT, newsletter INTEGER NOT NULL DEFAULT 0);
INSERT INTO profiles VALUES (1, 'ana', 1);

INSERT OR REPLACE INTO profiles (customer_id, nickname) VALUES (1, 'ana_i');
SELECT * FROM profiles;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*

| customer_id | nickname | newsletter |
|---|---|---|
| 1 | ana_i | 0 |
<!-- /result -->

`newsletter` silently went from 1 back to 0. Prefer `ON CONFLICT … DO UPDATE SET` the columns you mean to change.

## 5. Idempotency keys for API requests

The client sends a unique key with each logical request (for example a UUID in an `Idempotency-Key` header) and reuses it on retries. The server stores the key, a hash of the request, and the response, **in the same transaction as the side effect**:

```sql
CREATE TABLE idempotency_keys (
  idem_key      TEXT PRIMARY KEY,
  request_hash  TEXT NOT NULL,
  response_code INTEGER NOT NULL,
  order_id      INTEGER NOT NULL REFERENCES orders(order_id),
  created_at    TEXT NOT NULL
);

-- First attempt: do the work and record the outcome atomically.
BEGIN;
INSERT INTO orders VALUES (500, 3, '2026-09-10', 'pending');
INSERT INTO idempotency_keys VALUES ('k-123', 'hash:qty=2', 201, 500, '2026-09-10');
COMMIT;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*
<!-- /result -->

On every request the server first looks the key up and decides:

```sql
WITH incoming(idem_key, request_hash) AS (
  VALUES ('k-123', 'hash:qty=2'),   -- exact retry
         ('k-123', 'hash:qty=5'),   -- same key, different body: client bug
         ('k-999', 'hash:qty=1')    -- new request
)
SELECT i.idem_key, i.request_hash,
       CASE
         WHEN k.idem_key IS NULL               THEN 'new: do the work'
         WHEN k.request_hash = i.request_hash  THEN 'replay: return stored ' || k.response_code
         ELSE 'conflict: reject with 422'
       END AS decision
FROM incoming i
LEFT JOIN idempotency_keys k ON k.idem_key = i.idem_key;
```

<!-- result -->
| idem_key | request_hash | decision |
|---|---|---|
| k-123 | hash:qty=2 | replay: return stored 201 |
| k-123 | hash:qty=5 | conflict: reject with 422 |
| k-999 | hash:qty=1 | new: do the work |
<!-- /result -->

**Why compare the hash?** `ON CONFLICT DO NOTHING` alone would treat "same key, different payload" as success and return a response for a request that was never performed. Payment providers reject that case explicitly.

If two identical requests arrive at the same moment, both may find no key; both try to `INSERT` the key, and the primary key lets **one** win. The loser's transaction fails, rolls back its side effect, and it then re-reads the stored response.

## 6. Design checklist

- [ ] A unique constraint on whatever identifies "the same thing" (email, event ID, idempotency key).
- [ ] The side effect and the key are written in **one** transaction.
- [ ] Retries with the same key and payload return the **stored** result.
- [ ] The same key with a different payload is rejected.
- [ ] Keys expire after a documented period (a `created_at` and a clean-up job).
- [ ] Counters upserted from events are de-duplicated by event ID first.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| `SELECT` then `INSERT` to avoid duplicates | Duplicates under concurrency | Unique constraint + `ON CONFLICT` |
| `INSERT OR REPLACE` for updates | Other columns reset, cascades fire | `ON CONFLICT DO UPDATE SET` specific columns |
| `DO NOTHING` as a payment retry policy | Different payloads accepted as replays | Store and compare a request hash |
| Key written in a separate transaction | Key without side effect (or the reverse) after a crash | Same transaction |
| Counter upsert on replayed events | Inflated counts | De-duplicate by event ID |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PA08` | **Idempotency keys.** Create a table idempotency_keys(request_key TEXT, request_hash TEXT NOT NULL, response_code INTEGER NOT NULL, created_at TEXT NOT NULL) where request_key is unique. Then store ('req-1', 'h1', 201, '2026-11-01') twice so that the second attempt is silently ignored. The checker then tries to insert a duplicate key and a new key. | script |
| `PA09` | **UPSERT a counter.** Create category_views(category_id INTEGER PRIMARY KEY, views INTEGER NOT NULL). Record five view events for categories 1, 2, 1, 3, 1, one statement per event, using INSERT ... ON CONFLICT DO UPDATE so each category ends with its total. | script |
| `PA10` | **Replay or conflict?.** Start your query with these CTEs: stored(request_key, request_hash) AS (VALUES ('req-1','h1'), ('req-2','h2')) and incoming(request_key, request_hash) AS (VALUES ('req-1','h1'), ('req-2','hX'), ('req-3','h3')). Return request_key, decision for each incoming request: 'replay' if stored with the same hash, 'conflict' if stored with a different hash, 'new' if not stored. Sort by request_key. | query |
| `PA29` | **Subscribe once.** Create subscribers(email TEXT PRIMARY KEY, first_seen TEXT NOT NULL). Record the sign-ups ('ana@example.test', '2026-01-05'), ('bo@example.test', '2026-01-06'), ('ana@example.test', '2026-02-01') so that a repeat is ignored and the first date is kept. The checker then replays a sign-up. | script |
| `PA30` | **Keep the latest timestamp.** Create last_seen(product_id INTEGER PRIMARY KEY, seen_at TEXT NOT NULL). Record events (1, '2026-05-01'), (1, '2026-03-01'), (2, '2026-04-01') in that order with upserts so each product keeps its latest seen_at even when events arrive out of order. | script |

```bash
python tools/practice.py show PA08
python tools/practice.py check PA08
python tools/practice.py hint PA08 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** What reliably prevents duplicate inserts under concurrency?

   - **a)** SELECT first, then INSERT
   - **b)** A unique constraint
   - **c)** A transaction alone

**2.** In `ON CONFLICT … DO UPDATE SET units = units + excluded.units`, `excluded.units` is…

   - **a)** the stored value
   - **b)** the value from the INSERT that conflicted
   - **c)** always NULL

**3.** What does `INSERT OR REPLACE` do to columns you didn't supply?

   - **a)** Keeps them
   - **b)** Resets them to defaults, because it deletes and re-inserts
   - **c)** Raises an error

**4.** A retry arrives with a known idempotency key but a different payload. The server should…

   - **a)** return the stored response
   - **b)** reject it
   - **c)** process it as new

```bash
python tools/quiz.py advanced/04 1 b      # question 1, answer b
python tools/quiz.py advanced/04           # list the questions
```
<!-- /quiz -->

## Summary

- Only a unique constraint prevents duplicates under concurrency.
- `ON CONFLICT DO NOTHING` skips; `DO UPDATE SET … excluded.col` upserts atomically.
- `INSERT OR REPLACE` deletes and re-inserts. Avoid it for updates.
- Idempotency keys: store key, request hash and response with the side effect; replay or reject on retry.

**Next:** [05 · Triggers and audit history](05_triggers_audit.md)
