# Store Sales Report

**Scenario.** The shop owner wants a first sales report: what each paid order was worth, which products sell, and which products nobody has bought.

**You'll use:** Basics lessons [04](../lessons/04_aggregates.md)–[07](../lessons/07_left_join.md) and [09](../lessons/09_review.md).

Work in your own file (for example `my_01_store_sales_report.sql` in this folder) and run it with `python tools/run_sql.py`. Every run starts from a fresh sample database. The reference solution is [`01_store_sales_report.sql`](01_store_sales_report.sql); open it only after your own attempt.

## Tickets

### Ticket 1 · Paid order values

List every paid order with the customer's name and the order's value in cents.

**Acceptance**

- One row per paid order; pending and cancelled orders are absent.
- Value = Σ quantity × unit_price_cents of its lines.
- Sorted by value descending, ties by order_id.

### Ticket 2 · Best sellers

List products by units sold on paid orders.

**Acceptance**

- Units from pending orders (e.g. 10 pens in order 108) don't count.
- Sorted by units descending, then sku.

### Ticket 3 · Never purchased

List products that appear on no order line at all.

**Acceptance**

- Uses an anti-join (`NOT EXISTS` or `LEFT JOIN … IS NULL`).
- An empty result is correct for the sample data; prove the query works by adding a product inside `BEGIN … ROLLBACK`.

## Stretch goals

1. Add monthly paid revenue and check that it sums to the same total as ticket 1.
2. Rank categories by paid revenue.
3. List customers with no paid order, including any without orders at all.

## Review rubric

| Dimension | Points | Evidence |
|---|---:|---|
| Correctness | 40 | Every ticket's acceptance criteria hold on a fresh database |
| Edge cases | 20 | You state and test at least one edge case per ticket (empty group, NULL, tie, unmatched row) |
| Query design | 15 | Right grain, right join type, no fan-out, deterministic ordering |
| Readability | 15 | One query per ticket, a comment with the question it answers, aliases that read well |
| Verification | 10 | At least one independent cross-check of a total |

**Done when** your file runs top to bottom with `python tools/run_sql.py <your file>`, every acceptance criterion is met, and you can explain each query out loud. Then compare with the reference solution and note one thing it does differently.
