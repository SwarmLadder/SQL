# Worked example A5 · A backfill in batches

**Problem.** A new column `customers.lifetime_cents` must be filled for every existing customer. On a table with millions of rows, one giant `UPDATE` would lock writes for minutes. Do it in small, restartable batches.

**Run:** `python tools/run_sql.py advanced/worked_examples/05_batched_backfill.sql`

## 1. Expand: add the column

```sql
ALTER TABLE customers ADD COLUMN lifetime_cents INTEGER;
```

<!-- result -->
*Done (no rows returned).*
<!-- /result -->

Nullable for now, so old code keeps working and the backfill can tell which rows it has done (`IS NULL`).

## 2. Tempting attempt: one statement

```sql norun
UPDATE customers SET lifetime_cents = (SELECT … for this customer …);   -- every row in one transaction
```

Correct, but on a big table it holds the write lock for the whole run, grows the transaction log, and if it fails at 95% everything is rolled back.

## 3. Fix: batches by key range

Process customers in key order, a fixed number at a time. Each batch is its own short transaction, and only touches rows not done yet, so a crash can simply be resumed:

```sql
UPDATE customers
SET lifetime_cents = COALESCE((SELECT SUM(i.quantity * i.unit_price_cents)
                               FROM orders o JOIN order_items i ON i.order_id = o.order_id
                               WHERE o.customer_id = customers.customer_id AND o.status = 'paid'), 0)
WHERE customer_id IN (SELECT customer_id FROM customers
                      WHERE lifetime_cents IS NULL ORDER BY customer_id LIMIT 3);
SELECT COUNT(*) AS remaining FROM customers WHERE lifetime_cents IS NULL;
```

<!-- result -->
*Rows changed: 3*

| remaining |
|---|
| 5 |
<!-- /result -->

The application (or a script) repeats that statement until `remaining` is 0. Run it twice more here:

```sql
UPDATE customers
SET lifetime_cents = COALESCE((SELECT SUM(i.quantity * i.unit_price_cents)
                               FROM orders o JOIN order_items i ON i.order_id = o.order_id
                               WHERE o.customer_id = customers.customer_id AND o.status = 'paid'), 0)
WHERE customer_id IN (SELECT customer_id FROM customers
                      WHERE lifetime_cents IS NULL ORDER BY customer_id LIMIT 3);
UPDATE customers
SET lifetime_cents = COALESCE((SELECT SUM(i.quantity * i.unit_price_cents)
                               FROM orders o JOIN order_items i ON i.order_id = o.order_id
                               WHERE o.customer_id = customers.customer_id AND o.status = 'paid'), 0)
WHERE customer_id IN (SELECT customer_id FROM customers
                      WHERE lifetime_cents IS NULL ORDER BY customer_id LIMIT 3);
SELECT COUNT(*) AS remaining FROM customers WHERE lifetime_cents IS NULL;
```

<!-- result -->
*Rows changed: 3*

*Rows changed: 2*

| remaining |
|---|
| 0 |
<!-- /result -->

## 4. Verify, then contract

The backfilled values must match a fresh computation for every row, and the sum must match the paid total:

```sql
SELECT COUNT(*) AS wrong_rows
FROM customers c
WHERE c.lifetime_cents IS NOT COALESCE((SELECT SUM(i.quantity * i.unit_price_cents)
                                        FROM orders o JOIN order_items i ON i.order_id = o.order_id
                                        WHERE o.customer_id = c.customer_id AND o.status = 'paid'), 0);
SELECT SUM(lifetime_cents) AS backfilled_total FROM customers;
```

<!-- result -->
| wrong_rows |
|---|
| 0 |

| backfilled_total |
|---|
| 101950 |
<!-- /result -->

Zero wrong rows and 101 950 in total. Only now is it safe to make the column required, by rebuilding the table in SQLite or with `ALTER … SET NOT NULL` in PostgreSQL. New orders written *during* the backfill also need handling: either the application updates the column from the moment it exists, or a final catch-up pass re-runs for recently changed customers.

**Practise next:** [PA15](../../practice/starter/PA15.sql), [PA33](../../practice/starter/PA33.sql).
