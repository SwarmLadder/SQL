# Worked example A1 · From SCAN to SEARCH

**Problem.** An operations screen polls `SELECT order_id, customer_id, ordered_at FROM orders WHERE status = 'pending' ORDER BY ordered_at DESC LIMIT 20` every few seconds. Make it cheap without changing its result.

**Run:** `python tools/run_sql.py advanced/worked_examples/01_scan_to_search.sql`

## 1. Read the plan first

```
SCAN orders
USE TEMP B-TREE FOR ORDER BY
```

Two costs: every row is read (`SCAN`), and the matches are sorted in a temporary structure before `LIMIT` can stop early. The existing `idx_orders_customer_date` doesn't help because the query never filters on `customer_id`.

## 2. Design the index from the query

| Clause | Role | Index position |
|---|---|---|
| `status = 'pending'` | equality filter | first |
| `ORDER BY ordered_at DESC` | sort | second (SQLite walks the index backwards for `DESC`) |

```sql
CREATE INDEX idx_orders_status_date ON orders(status, ordered_at);
```

## 3. Read the plan again

```
SEARCH orders USING INDEX idx_orders_status_date (status=?)
```

No scan and no temp B-tree: SQLite jumps to the `pending` entries, already in date order, and stops after 20.

## 4. What it costs

Every `INSERT` into orders and every `UPDATE` of `status` or `ordered_at` now also updates this index, and it takes disk space. On a table where status changes constantly, measure write latency before and after. Also confirm the result is identical before and after: the script prints it. The plan is about speed, never about correctness.

**Practise next:** [PA01](../../practice/starter/PA01.sql) and the written task PA02.
