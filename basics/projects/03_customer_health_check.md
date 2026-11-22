# Customer Health Check

**Scenario.** Customer success wants to know who is active, who needs a follow-up, and whether the data itself can be trusted before a campaign goes out.

**You'll use:** Basics lessons [05](../lessons/05_group_by_having.md)–[07](../lessons/07_left_join.md) and [09](../lessons/09_review.md).

Work in your own file (for example `my_03_customer_health_check.sql` in this folder) and run it with `python tools/run_sql.py`. Every run starts from a fresh sample database. The reference solution is [`03_customer_health_check.sql`](03_customer_health_check.sql); open it only after your own attempt.

## Tickets

### Ticket 1 · Customer directory

One row per customer with total orders, paid orders and the date of their last order.

**Acceptance**

- Customers without orders appear with 0 and NULL.
- Sorted by customer_id.

### Ticket 2 · Follow-up list

Customers who placed orders but never had one paid.

**Acceptance**

- Elena (customer 5) is the only result in the sample data.
- Customers with no orders at all are *not* on this list.

### Ticket 3 · Data quality

(a) Inactive products that appear on paid orders. (b) Orders that have no lines.

**Acceptance**

- (a) finds the inactive Folder (P09) on paid order 109. Write one sentence on whether that's a bug.
- (b) returns no rows today; show that it would catch an order without lines.

### Ticket 4 · City summary

Customers and paid revenue per city, biggest revenue first.

**Acceptance**

- Cities whose customers never paid show 0, not NULL.
- Paid revenue across cities equals the paid total from the Store Sales Report (101 950).

## Stretch goals

1. Add a customer with no orders inside a transaction and confirm every ticket still behaves.
2. Find customers whose only orders are pending.
3. Show each customer's share of total paid revenue (you'll meet window functions in Intermediate).

## Review rubric

| Dimension | Points | Evidence |
|---|---:|---|
| Correctness | 40 | Every ticket's acceptance criteria hold on a fresh database |
| Edge cases | 20 | You state and test at least one edge case per ticket (empty group, NULL, tie, unmatched row) |
| Query design | 15 | Right grain, right join type, no fan-out, deterministic ordering |
| Readability | 15 | One query per ticket, a comment with the question it answers, aliases that read well |
| Verification | 10 | At least one independent cross-check of a total |

**Done when** your file runs top to bottom with `python tools/run_sql.py <your file>`, every acceptance criterion is met, and you can explain each query out loud. Then compare with the reference solution and note one thing it does differently.
