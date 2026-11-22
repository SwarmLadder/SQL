# Customer Activity and Retention

**Scenario.** Growth wants to understand the customer lifecycle: when people first order, whether they come back, and how sign-up month relates to their first payment.

**You'll use:** Intermediate lessons [02](../lessons/02_exists.md), [03](../lessons/03_cte.md), [04](../lessons/04_case_conditional.md), [07](../lessons/07_dates_strings.md).

Work in your own file (for example `my_02_customer_activity.sql` in this folder) and run it with `python tools/run_sql.py`. Every run starts from a fresh sample database. The reference solution is [`02_customer_activity.sql`](02_customer_activity.sql); open it only after your own attempt.

## Tickets

### Ticket 1 · Activity per customer

First and latest order date and order count for every customer.

**Acceptance**

- Customers without orders appear with 0 and NULL dates.
- One row per customer.

### Ticket 2 · Paid behaviour

Paid orders, sign-up month, first paid month and a repeat-buyer flag.

**Acceptance**

- The repeat flag is 1 only with two or more paid orders.
- Months are formatted YYYY-MM.

## Stretch goals

1. Percentage of customers who placed at least one paid order.
2. Customers with an order but no paid order, written once with `EXCEPT` and once with `NOT EXISTS`; prove they agree.
3. Sign-ups per month, including months with zero (needs a calendar).

## Review rubric

| Dimension | Points | Evidence |
|---|---:|---|
| Correctness | 40 | Every ticket's acceptance criteria hold on a fresh database |
| Edge cases | 20 | You state and test at least one edge case per ticket (empty group, NULL, tie, unmatched row) |
| Query design | 15 | Right grain, right join type, no fan-out, deterministic ordering |
| Readability | 15 | One query per ticket, a comment with the question it answers, aliases that read well |
| Verification | 10 | At least one independent cross-check of a total |

**Done when** your file runs top to bottom with `python tools/run_sql.py <your file>`, every acceptance criterion is met, and you can explain each query out loud. Then compare with the reference solution and note one thing it does differently.
