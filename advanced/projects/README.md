# Advanced projects

Each project is a set of tickets with acceptance criteria, like real work. Write your own SQL file first, run it with `python tools/run_sql.py <file>`, then compare with the reference solution.

| # | Project | Scenario | Reference |
|---|---|---|---|
| 01 | [Order and Payment Reconciliation](01_order_reconciliation.md) | Finance closes the month only when every paid order has been paid exactly its value. Build the reconciliation they run, and make it impossible to miss a problem. | [SQL](01_order_reconciliation.sql) |
| 02 | [Audited Price Changes](02_audited_price_changes.md) | Pricing changes must be traceable: every real change recorded, risky changes reversible, and the limits of the audit documented for the security review. | [SQL](02_audited_price_changes.sql) |
| 03 | [Idempotent Payment Intake](03_payment_intake.md) | The payment provider calls a webhook for every successful payment and retries deliveries it isn't sure about. Design the database side so retries are harmless, conflicting deliveries raise an alert, and the books always reconcile. | [SQL](03_payment_intake.sql) |

Every project uses the same 100-point review rubric (in each brief). Aim for 80+.
