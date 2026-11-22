# Cohort and Retention Report

**Scenario.** The marketing team runs campaigns per sign-up month and needs a cohort report: how many customers each month brought in, how many converted, how quickly, and who came back.

**You'll use:** Intermediate lessons [03](../lessons/03_cte.md), [04](../lessons/04_case_conditional.md), [06](../lessons/06_windows_running.md), [07](../lessons/07_dates_strings.md), [09](../lessons/09_views_savepoints.md).

Work in your own file (for example `my_03_cohort_retention.sql` in this folder) and run it with `python tools/run_sql.py`. Every run starts from a fresh sample database. The reference solution is [`03_cohort_retention.sql`](03_cohort_retention.sql); open it only after your own attempt.

## Tickets

### Ticket 1 · Per-customer facts

A CTE with one row per customer: cohort (sign-up month), first paid order date, number of paid orders.

**Acceptance**

- Customers without paid orders have NULL first paid date and 0 orders.
- Exactly one row per customer (check `COUNT(*)` vs `COUNT(DISTINCT customer_id)`).

### Ticket 2 · Cohort table

Per cohort: customers, converted (≥1 paid), repeat buyers (≥2 paid), conversion % and average days to first paid order.

**Acceptance**

- The 2026-03 cohort shows 50.0% because Elena never paid.
- Percentages use real division (`100.0 *`).

### Ticket 3 · Time between orders

Per customer with repeat orders: number of repeat orders and average gap in days, using `LAG`.

**Acceptance**

- Customers with a single order are excluded.
- Gaps are whole days.

### Ticket 4 · Lifecycle view

A view `customer_lifecycle` with stage = registered / tried / converted / repeat, and a count per stage.

**Acceptance**

- Every customer is in exactly one stage.
- The view updates automatically when an order is added (show it inside `BEGIN … ROLLBACK`).

## Stretch goals

1. Add 30- and 60-day conversion columns per cohort.
2. Show each cohort's revenue and revenue per customer.
3. Rank cohorts by conversion with `DENSE_RANK`.

## Review rubric

| Dimension | Points | Evidence |
|---|---:|---|
| Correctness | 40 | Every ticket's acceptance criteria hold on a fresh database |
| Edge cases | 20 | You state and test at least one edge case per ticket (empty group, NULL, tie, unmatched row) |
| Query design | 15 | Right grain, right join type, no fan-out, deterministic ordering |
| Readability | 15 | One query per ticket, a comment with the question it answers, aliases that read well |
| Verification | 10 | At least one independent cross-check of a total |

**Done when** your file runs top to bottom with `python tools/run_sql.py <your file>`, every acceptance criterion is met, and you can explain each query out loud. Then compare with the reference solution and note one thing it does differently.
