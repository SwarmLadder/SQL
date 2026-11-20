# Order and Payment Reconciliation

**Deliverables**
- Reconcile paid order item totals against recorded payments.
- Keep pending/cancelled orders visible with clear status.
- Flag missing or mismatched payments without multiplying rows.

**Run:** `python tools/run_sql.py advanced/projects/01_order_reconciliation.sql`

**Extend**
1. Simulate an incorrect payment and rerun the reconciliation.
2. Add reconciliation counts by status.
3. Design a database constraint or transactional workflow that prevents mismatched writes.

**Done when:** your queries run on a fresh database and results match the stated business definitions.
