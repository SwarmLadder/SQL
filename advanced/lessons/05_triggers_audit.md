# 05 · Triggers and audit history

> **You will learn** to run SQL automatically on `INSERT`, `UPDATE` and `DELETE` with triggers, to read `OLD` and `NEW` values, to reject invalid changes with `RAISE(ABORT, …)`, to record an audit trail, and where triggers stop being a good idea.
> **Time:** about 55 minutes · **Before this:** [04 · UPSERT and idempotency keys](04_upsert_idempotency.md)

A **trigger** is SQL the database runs for you whenever a matching write happens. It sits next to the data, so it fires no matter which application or script made the change. That's its strength, and its danger.

**Run the whole lesson:** `python tools/run_sql.py advanced/lessons/05_triggers_audit.sql`

## 1. Anatomy of a trigger

```sql norun
CREATE TRIGGER name
{BEFORE | AFTER} {INSERT | UPDATE [OF col, …] | DELETE} ON table
[WHEN condition]
BEGIN
  statements;   -- may use OLD.col (UPDATE/DELETE) and NEW.col (INSERT/UPDATE)
END;
```

- `OLD` is the row before the change, `NEW` the row after. An `INSERT` has only `NEW`, a `DELETE` only `OLD`.
- SQLite triggers run **for each row** affected.
- The trigger runs inside the same transaction as the statement that fired it. If the trigger fails, the whole statement is undone.

## 2. Recording an audit trail

Log every price change with the old and new value:

```sql
CREATE TABLE price_audit (
  audit_id INTEGER PRIMARY KEY,
  product_id INTEGER NOT NULL,
  old_price_cents INTEGER NOT NULL,
  new_price_cents INTEGER NOT NULL,
  changed_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TRIGGER audit_price_change
AFTER UPDATE OF unit_price_cents ON products
WHEN OLD.unit_price_cents <> NEW.unit_price_cents
BEGIN
  INSERT INTO price_audit (product_id, old_price_cents, new_price_cents)
  VALUES (NEW.product_id, OLD.unit_price_cents, NEW.unit_price_cents);
END;

UPDATE products SET unit_price_cents = 1300 WHERE product_id = 1;   -- logged
UPDATE products SET unit_price_cents = 250  WHERE product_id = 2;   -- same value: not logged
UPDATE products SET active = 0 WHERE product_id = 3;                -- other column: not fired

SELECT product_id, old_price_cents, new_price_cents FROM price_audit;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*

*Rows changed: 1*

| product_id | old_price_cents | new_price_cents |
|---|---|---|
| 1 | 1200 | 1300 |
<!-- /result -->

- `UPDATE OF unit_price_cents` fires only when that column is **assigned**, even to the same value. The `WHEN` clause filters out no-op changes.
- `changed_at` defaults to the current time, so it's left out here to keep the output stable.

## 3. Rejecting invalid changes

A `BEFORE` trigger can stop a write with `RAISE(ABORT, 'message')`. Here, prices may never rise by more than 50% in one step:

```sql
CREATE TRIGGER limit_price_jump
BEFORE UPDATE OF unit_price_cents ON products
WHEN NEW.unit_price_cents > OLD.unit_price_cents * 3 / 2
BEGIN
  SELECT RAISE(ABORT, 'price increase above 50% needs approval');
END;
```

<!-- result -->
*Done (no rows returned).*
<!-- /result -->

```sql error
UPDATE products SET unit_price_cents = 99900 WHERE product_id = 4;
```

<!-- result -->
**Error:** `price increase above 50% needs approval`
<!-- /result -->

`ABORT` undoes the current statement (and leaves earlier statements of the transaction alone). Use `CHECK` constraints where a rule only involves one row's own columns, because they're simpler and visible in the schema. Triggers are for rules that compare `OLD` with `NEW` or look at other tables.

## 4. Keeping a derived value in sync

Triggers can maintain a summary: a per-order line count updated on every insert and delete.

```sql
CREATE TABLE order_line_counts (order_id INTEGER PRIMARY KEY, line_count INTEGER NOT NULL);
INSERT INTO order_line_counts SELECT order_id, COUNT(*) FROM order_items GROUP BY order_id;

CREATE TRIGGER count_line_insert AFTER INSERT ON order_items
BEGIN
  INSERT INTO order_line_counts VALUES (NEW.order_id, 1)
  ON CONFLICT(order_id) DO UPDATE SET line_count = line_count + 1;
END;

CREATE TRIGGER count_line_delete AFTER DELETE ON order_items
BEGIN
  UPDATE order_line_counts SET line_count = line_count - 1 WHERE order_id = OLD.order_id;
END;

INSERT INTO order_items VALUES (101, 3, 1, 4900);
DELETE FROM order_items WHERE order_id = 104;
SELECT order_id, line_count FROM order_line_counts WHERE order_id IN (101, 104);
```

<!-- result -->
*Rows changed: 11*

*Rows changed: 1*

*Rows changed: 1*

| order_id | line_count |
|---|---|
| 101 | 3 |
| 104 | 0 |
<!-- /result -->

It works, but every write to `order_items` now does extra hidden work, and an `UPDATE` that moves a line to another order isn't handled at all. That's the typical trade-off.

## 5. Why a trigger is not audit security

The `price_audit` table records *what* changed. On its own it cannot be trusted as evidence:

| Gap | Why | What closes it |
|---|---|---|
| **Who** made the change | SQLite has no users; PostgreSQL's `current_user` is often one shared application account | The application passes the real user ID; log it in the same transaction |
| Anyone who can write the table can also edit or delete the audit rows | Same permissions | Separate role with insert-only rights; append-only storage |
| Anyone with schema rights can `DROP TRIGGER` | DDL is just SQL | Restrict DDL; alert on schema changes |
| Bulk loads may bypass triggers | Tools that write files directly, or `PRAGMA`s | Controlled load paths |
| Retention, tamper evidence | Rows can be quietly removed later | Ship logs to an external, write-once store; hash chains |

A trigger is a convenient *recording* mechanism. Trust comes from permissions, identity and storage around it.

## 6. When not to use triggers

- **Business workflows** (send an email, call an API): a trigger can't do it, and shouldn't wait for it.
- **Chains** of triggers firing triggers: hard to debug, easy to loop.
- **Logic the application team doesn't know exists**: surprises in production.

Keep triggers small, documented in the schema, and limited to integrity and recording.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| `UPDATE OF col` without `WHEN OLD.col <> NEW.col` | Audit rows for no-op updates | Add the `WHEN` clause (and handle NULL with `IS NOT`) |
| Business rules hidden in triggers | Nobody knows why writes fail | Document; prefer `CHECK` and application logic |
| Trusting the audit table as evidence | Edited or deleted audit rows | Permissions, real identity, external storage |
| Forgetting `UPDATE` in a sync trigger | Derived counts drift | Handle every write path, or recompute periodically |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PA11` | **Price change log.** Create price_changes(product_id INTEGER, old_price_cents INTEGER, new_price_cents INTEGER) and a trigger that adds a row whenever a product's unit_price_cents actually changes. Updates that leave the price the same, or touch only other columns, must not log anything. The checker runs three updates. | script |
| `PA12` | **Why triggers are not audit security.** Your price_changes trigger records changes made through normal UPDATE statements. List at least three ways a change could happen without a trustworthy log entry (think about who can drop triggers, edit the log table, or write outside the database), and what you would add to make the audit trail reliable. | written ✍️ |
| `PA31` | **Paid orders can't be deleted.** Create a trigger that rejects, with RAISE(ABORT, …), any DELETE of an order whose status is 'paid'. Other orders may still be deleted. The checker deletes an order's children and then the order, for one paid and one cancelled order. | script |
| `PA32` | **Status change log.** Create status_log(order_id INTEGER, old_status TEXT, new_status TEXT) and a trigger that logs every real change of orders.status (not no-op updates, not updates of other columns). The checker runs three updates. | script |

```bash
python tools/practice.py show PA11
python tools/practice.py check PA11
python tools/practice.py hint PA11 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** Inside an UPDATE trigger, OLD and NEW are…

   - **a)** the row before and after the change
   - **b)** the previous and next statement
   - **c)** two tables

**2.** Why add `WHEN OLD.price <> NEW.price` to an `AFTER UPDATE OF price` trigger?

   - **a)** UPDATE OF fires even when the value is assigned unchanged
   - **b)** It's required syntax
   - **c)** To make it faster

**3.** What does `RAISE(ABORT, 'msg')` in a BEFORE trigger do?

   - **a)** Logs a warning
   - **b)** Undoes the current statement with an error
   - **c)** Rolls back all past transactions

**4.** Why isn't a trigger-based audit table trustworthy evidence on its own?

   - **a)** Writers with access can edit it or drop the trigger, and it doesn't know the real user
   - **b)** Triggers can't insert rows
   - **c)** It is always trustworthy

```bash
python tools/quiz.py advanced/05 1 b      # question 1, answer b
python tools/quiz.py advanced/05           # list the questions
```
<!-- /quiz -->

## Summary

- Triggers run SQL for each affected row, inside the same transaction, with `OLD` and `NEW` available.
- `AFTER` triggers record (audit, summaries); `BEFORE` + `RAISE(ABORT)` rejects changes.
- Use `WHEN` to skip no-op changes; prefer `CHECK` constraints for single-row rules.
- A trigger records changes but doesn't make an audit trustworthy. That needs identity, permissions and storage.

**Next:** [06 · Summary tables and freshness](06_summary_tables.md)
