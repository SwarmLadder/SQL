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
