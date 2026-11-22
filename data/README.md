# Sample database

A small, fictional online store. SQL scripts use integer cents for prices and payments.

| Table | Purpose |
|---|---|
| customers | Customer profiles |
| categories, products | Product catalog |
| orders, order_items | Purchases and line items |
| payments | Recorded payments |
| teams, employees | Employees and managers |
| audit_events | Example events |

- [schema.sql](schema.sql): tables, constraints, indexes.
- [seed.sql](seed.sql): fictional sample rows.
- Test emails use `example.test`; names and orders are synthetic.

**No setup needed:** the [runner](../tools/run_sql.py) loads both files into memory before running a lesson.

## Fixtures used by the checkers

Every graded answer runs twice: once on the data above and once on an **edge-case fixture** that adds rows designed to break careless queries. The extra rows are defined in code, so the course data itself never changes:

| Added row(s) | Catches |
|---|---|
| Customer 9 *Iris Test* (Bucharest), team 4 *Operations* with no employees, category 5 *Gifts* | inner joins that should be left joins; "empty group" cases |
| Product P10 at 250 cents, never ordered | anti-joins; ties in price sorting |
| Employee 9 *Ivana* reporting to Ada, Engineering's second-highest salary | top-N per group, ranking |
| Paid order 112 (customer 8) and pending order 113 | per-customer counts, status filters |
| Payment 1 reduced by 100 cents | reconciliation queries that never flag a mismatch |
| *Practice only:* product P11 bought only in a cancelled order | "never paid for" vs "never ordered" |
| *Practice only:* a large pending order 115 | forgetting the `status = 'paid'` filter in top-N lists |
| *Practice only:* customer 10 with no orders at all | `COUNT(*)` after a `LEFT JOIN` |

The interview fixture is `EDGE_SQL` in [`tools/interview_practice.py`](../tools/interview_practice.py); the practice checker adds `PRACTICE_EDGE_SQL` from [`tools/practice.py`](../tools/practice.py).
