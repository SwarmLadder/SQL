# Worked example I2 · A signup cohort table

**Problem.** Product asks: "For each signup month, how many customers never ordered, paid once, or came back and paid again?"

**Run:** `python tools/run_sql.py intermediate/worked_examples/02_cohort_pivot.sql`

## 1. Shape the data in two stages

Trying to do everything in one `GROUP BY cohort` mixes two grains: orders and customers. Count orders per customer first, *then* count customers per cohort.

1. `per_customer`: one row per customer with `cohort`, `paid_orders` and `all_orders`. `LEFT JOIN` keeps customers with no orders; `COUNT(o.order_id)` counts 0 for them (whereas `COUNT(*)` would count 1).
2. Final query: one row per cohort; each output column is a `SUM(CASE ...)` over customers.

## 2. Result

| cohort | customers | never_ordered | paid_once | paid_repeat | paying_pct |
|---|---:|---:|---:|---:|---:|
| 2026-01 | 2 | 0 | 1 | 1 | 100.0 |
| 2026-02 | 2 | 0 | 2 | 0 | 100.0 |
| 2026-03 | 2 | 0 | 1 | 0 | 50.0 |
| 2026-04 | 1 | 0 | 1 | 0 | 100.0 |
| 2026-05 | 1 | 0 | 1 | 0 | 100.0 |

## 3. Check the numbers

- `never_ordered + paid_once + paid_repeat` can be **less** than `customers`: a customer whose only order was cancelled (Elena, 2026-03) is in none of those columns. That's why `paying_pct` is 50.0. Decide with the stakeholder whether you need a fourth column.
- `100.0 *` forces real division. `100 * 1 / 2` is integer division in SQLite and gives 50 only by luck; `1 / 3` would give 0.
- The sum of `customers` must equal `SELECT COUNT(*) FROM customers` (8).

**Practise next:** [PI07](../../practice/starter/PI07.sql), [PI08](../../practice/starter/PI08.sql).
