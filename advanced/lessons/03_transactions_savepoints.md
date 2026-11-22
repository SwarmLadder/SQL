# 03 · Atomic changes and savepoints

> **You will learn** the ACID guarantees, to design multi-step writes that can't be left half-done, to prevent lost updates with conditional writes and version columns, how savepoints nest, and how isolation and locking differ between SQLite and PostgreSQL.
> **Time:** about 60 minutes · **Before this:** [Intermediate 09 · Views, savepoints, and transactions](../../intermediate/lessons/09_views_savepoints.md)

Intermediate introduced `BEGIN`, `COMMIT`, `ROLLBACK` and savepoints. Here we use them the way production systems must: under **concurrency**, where two requests touch the same rows at the same time, and under **failure**, where a process can die between any two statements.

**Run the whole lesson:** `python tools/run_sql.py advanced/lessons/03_transactions_savepoints.sql`

## 1. ACID in one table

| Property | Promise | Your job |
|---|---|---|
| **Atomicity** | All statements of a transaction take effect, or none | Put every step of one business action in one transaction |
| **Consistency** | Constraints hold after every commit | Declare the rules as constraints |
| **Isolation** | Concurrent transactions don't see each other's half-done work | Know your isolation level and its anomalies |
| **Durability** | Committed data survives a crash | Don't report success before `COMMIT` returns |

## 2. A transfer that can't half-happen

Moving 500 cents of "credit" between two customers is two updates. A crash between them would create or destroy money, so both go in one transaction, and the transaction checks its own preconditions:

```sql
CREATE TABLE wallets (
  customer_id INTEGER PRIMARY KEY REFERENCES customers(customer_id),
  balance_cents INTEGER NOT NULL CHECK (balance_cents >= 0)
);
INSERT INTO wallets VALUES (1, 1000), (2, 200);

BEGIN;
UPDATE wallets SET balance_cents = balance_cents - 500 WHERE customer_id = 1;
UPDATE wallets SET balance_cents = balance_cents + 500 WHERE customer_id = 2;
COMMIT;

SELECT customer_id, balance_cents, SUM(balance_cents) OVER () AS total FROM wallets;
```

<!-- result -->
*Rows changed: 2*

*Rows changed: 1*

*Rows changed: 1*

| customer_id | balance_cents | total |
|---|---|---|
| 1 | 500 | 1200 |
| 2 | 700 | 1200 |
<!-- /result -->

The `CHECK (balance_cents >= 0)` makes an overdraft impossible: if a customer tries to send more than they have, the `UPDATE` fails and the application rolls the transaction back:

```sql error
UPDATE wallets SET balance_cents = balance_cents - 5000 WHERE customer_id = 2;
```

<!-- result -->
**Error:** `CHECK constraint failed: balance_cents >= 0`
<!-- /result -->

The invariant "the total never changes" is checked by the `SUM(...) OVER ()` column: it's still 1 200.

## 3. Lost updates and how to stop them

**Lost update:** two requests read the same row, both compute a new value, and the second write silently overwrites the first.

```text
Request A: SELECT balance → 700        Request B: SELECT balance → 700
Request A: UPDATE SET balance = 600    Request B: UPDATE SET balance = 650
Result: 650. A's withdrawal of 100 vanished.
```

**Fix 1: compute in the database, conditionally.** The read and the write become one atomic statement, and the condition guards the invariant:

```sql
UPDATE wallets
SET balance_cents = balance_cents - 100
WHERE customer_id = 2 AND balance_cents >= 100;

SELECT changes() AS rows_changed, balance_cents FROM wallets WHERE customer_id = 2;
```

<!-- result -->
*Rows changed: 1*

| rows_changed | balance_cents |
|---|---|
| 1 | 600 |
<!-- /result -->

`changes()` (or the driver's row count) is 1 if the withdrawal happened and 0 if the balance was too low. **Always check it.**

**Fix 2: optimistic locking with a version column**, for edits a user makes in a form:

```sql
ALTER TABLE wallets ADD COLUMN version INTEGER NOT NULL DEFAULT 1;

-- The client read version 1. Its update only succeeds if nobody changed the row since.
UPDATE wallets SET balance_cents = 999, version = version + 1
WHERE customer_id = 1 AND version = 1;
SELECT changes() AS first_writer;

-- A second client, also holding version 1, now fails cleanly instead of overwriting.
UPDATE wallets SET balance_cents = 111, version = version + 1
WHERE customer_id = 1 AND version = 1;
SELECT changes() AS second_writer;
```

<!-- result -->
| first_writer |
|---|
| 1 |

| second_writer |
|---|
| 0 |
<!-- /result -->

The second writer gets 0 rows changed and must reload and retry, or show "someone else edited this".

## 4. Nested savepoints

Savepoints nest. `ROLLBACK TO` undoes back to *that* savepoint (including any savepoints inside it) and leaves the outer work intact:

```sql
BEGIN;
UPDATE products SET unit_price_cents = 1300 WHERE product_id = 1;   -- keep
SAVEPOINT outer_step;
UPDATE products SET unit_price_cents = 300 WHERE product_id = 2;    -- keep
SAVEPOINT inner_step;
UPDATE products SET unit_price_cents = 1 WHERE product_id = 6;      -- undo
ROLLBACK TO inner_step;
RELEASE outer_step;
COMMIT;

SELECT product_id, unit_price_cents FROM products WHERE product_id IN (1, 2, 6) ORDER BY product_id;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*

*Rows changed: 1*

| product_id | unit_price_cents |
|---|---|
| 1 | 1300 |
| 2 | 300 |
| 6 | 450 |
<!-- /result -->

`RELEASE outer_step` also releases `inner_step`. Applications use this for batch imports: a savepoint per record, `ROLLBACK TO` on a bad record, and one commit at the end.

## 5. Isolation: SQLite vs PostgreSQL

| | SQLite | PostgreSQL (default `READ COMMITTED`) |
|---|---|---|
| Concurrent writers | One at a time per database file; others wait or get `SQLITE_BUSY` | Many; conflicts are per row |
| What a reader sees | A consistent snapshot of the last commit | Each *statement* sees data committed before it started |
| Lost updates | Impossible within one write transaction, since writes are serialised | Possible with read-then-write: use conditional `UPDATE`, `SELECT … FOR UPDATE`, or `SERIALIZABLE` |
| Start writing early | `BEGIN IMMEDIATE` takes the write lock up front and avoids deadlock on upgrade | `SELECT … FOR UPDATE` locks the rows you will change |

The patterns in section 3 are correct on **both**, which is why they're the default advice. The [PostgreSQL labs](../postgresql/README.md) show `FOR UPDATE`, `SKIP LOCKED` and isolation levels hands-on.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Each step of a business action in its own transaction | Half-finished state after a crash | One transaction per business action |
| Read, compute in the app, write back | Lost updates under load | Compute in the `UPDATE`, with a condition |
| Ignoring the affected row count | Silent no-ops look like success | Check `changes()` / row count every time |
| Long transactions holding locks | Timeouts and `database is locked` | Do slow work (HTTP calls, files) outside |
| Reporting success before `COMMIT` returns | "Saved" data that isn't | Commit, then respond |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PA07` | **Roll back two updates.** In one transaction: create a savepoint, set product 4's price to 14900 and product 8's price to 5900, roll back to the savepoint (undoing both), then deactivate product 2 (active = 0) and commit. The checker reads products 2, 4 and 8 afterwards. | script |
| `PA27` | **Withdraw only if covered.** Create wallets(customer_id INTEGER PRIMARY KEY, balance_cents INTEGER NOT NULL CHECK (balance_cents >= 0)) with (1, 1000) and (2, 200). Then withdraw 300 cents from each wallet with conditional UPDATEs that succeed only when the balance covers it. The script must not fail. | script |
| `PA28` | **Optimistic locking.** Create documents(doc_id INTEGER PRIMARY KEY, body TEXT NOT NULL, version INTEGER NOT NULL) with (1, 'draft', 1). Two clients both read version 1. Write client A's save (body 'A') and then client B's save (body 'B'), each as an UPDATE that only succeeds if the version is still the one they read, and bumps the version. | script |

```bash
python tools/practice.py show PA07
python tools/practice.py check PA07
python tools/practice.py hint PA07 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** Which statement prevents a lost update on a balance?

   - **a)** SELECT balance, then UPDATE SET balance = <computed value>
   - **b)** UPDATE … SET balance = balance - 100 WHERE id = ? AND balance >= 100
   - **c)** Two separate transactions

**2.** In optimistic locking, the second writer with a stale version…

   - **a)** overwrites the first
   - **b)** changes 0 rows and must reload
   - **c)** gets a deadlock

**3.** `ROLLBACK TO outer` when `inner` was created after `outer`…

   - **a)** undoes both inner and outer work since outer
   - **b)** undoes only inner
   - **c)** commits everything

**4.** How many writers can change a SQLite database file at the same moment?

   - **a)** One
   - **b)** Unlimited
   - **c)** One per table

```bash
python tools/quiz.py advanced/03 1 b      # question 1, answer b
python tools/quiz.py advanced/03           # list the questions
```
<!-- /quiz -->

## Summary

- Put every step of one business action in one transaction; let constraints guard invariants.
- Prevent lost updates by computing in the `UPDATE` with a condition, or with a version column, and always check the row count.
- Savepoints nest; `ROLLBACK TO` undoes to that point and keeps the transaction open.
- SQLite serialises writers; PostgreSQL allows concurrent writers, so read-then-write needs care.

**Next:** [04 · UPSERT and idempotency keys](04_upsert_idempotency.md)
