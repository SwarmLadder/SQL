# Worked example B2 · Each customer's first order

**Problem.** Return one row per customer with the id and date of their first order.

**Run:** `python tools/run_sql.py basics/worked_examples/02_first_order.sql`

## 1. The tempting query

```sql norun
SELECT customer_id, order_id, MIN(ordered_at) FROM orders GROUP BY customer_id;
```

`order_id` is neither grouped nor aggregated. PostgreSQL, SQL Server and MySQL (in its default mode) **reject** this. SQLite accepts it and, as a documented special case, takes the bare column from the row that holds the `MIN`. On this dataset the answer is right, which is exactly why the habit is dangerous: add a second aggregate or a tie and the bare column comes from an arbitrary row.

## 2. Portable version

Split the question in two:

1. *When* was each customer's first order? `SELECT customer_id, MIN(ordered_at) ... GROUP BY customer_id`
2. *Which* order was that? Join the result back to `orders` on customer **and** date.

Two orders on the same first day would produce two rows, so a tie-breaker is part of the specification: here the lowest `order_id` wins (`MIN(o.order_id)` with a second `GROUP BY`).

## 3. Test it

| Case | Expected |
|---|---|
| Customer with several orders (1: 101, 103) | 101 / 2026-01-12 |
| Customer whose first order was cancelled (5) | still listed, because the question said *first order*, not *first paid order* |
| Customer with no orders | not listed. If the report needs them, start from `customers` with a `LEFT JOIN` |

In the Intermediate level the same problem becomes a one-liner with `ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY ordered_at, order_id)`.

**Practise next:** [PB14](../../practice/starter/PB14.sql), [PI12](../../practice/starter/PI12.sql).
