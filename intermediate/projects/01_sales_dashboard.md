# Sales Dashboard with CTEs and Windows

**Scenario.** Leadership wants a monthly dashboard: revenue, order count, change versus last month, year-to-date, and a ranked list of the most valuable customers.

**You'll use:** Intermediate lessons [00](../lessons/00_multi_table_reports.md), [03](../lessons/03_cte.md), [05](../lessons/05_windows_ranking.md), [06](../lessons/06_windows_running.md).

Work in your own file (for example `my_01_sales_dashboard.sql` in this folder) and run it with `python tools/run_sql.py`. Every run starts from a fresh sample database. The reference solution is [`01_sales_dashboard.sql`](01_sales_dashboard.sql); open it only after your own attempt.

## Tickets

### Ticket 1 · Monthly revenue

Paid revenue and number of paid orders per month.

**Acceptance**

- Built from an `order_totals` CTE at one row per paid order.
- The months sum to the overall paid total.

### Ticket 2 · Trend columns

Add previous month's revenue (`LAG`) and a running year-to-date total.

**Acceptance**

- The first month's previous value is NULL.
- The year-to-date of the last month equals the overall total.

### Ticket 3 · Customer value ranking

Every customer with lifetime paid value and a `DENSE_RANK`.

**Acceptance**

- Customers without paid orders appear with 0.
- No fan-out: values match a direct per-customer sum.

## Stretch goals

1. Add month-over-month change in percent, guarding against division by zero with `NULLIF`.
2. Add revenue per category per month as a pivot.
3. Add a complete calendar (Advanced lesson 02) so months without sales show 0.

## Review rubric

| Dimension | Points | Evidence |
|---|---:|---|
| Correctness | 40 | Every ticket's acceptance criteria hold on a fresh database |
| Edge cases | 20 | You state and test at least one edge case per ticket (empty group, NULL, tie, unmatched row) |
| Query design | 15 | Right grain, right join type, no fan-out, deterministic ordering |
| Readability | 15 | One query per ticket, a comment with the question it answers, aliases that read well |
| Verification | 10 | At least one independent cross-check of a total |

**Done when** your file runs top to bottom with `python tools/run_sql.py <your file>`, every acceptance criterion is met, and you can explain each query out loud. Then compare with the reference solution and note one thing it does differently.
