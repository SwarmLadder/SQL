# Audited Price Changes

**Deliverables**
- Use a trigger to record meaningful price changes.
- Demonstrate a savepoint rollback restoring changed records.
- Explain audit limitations around user identity and retention.

**Run:** `python tools/run_sql.py advanced/projects/02_audited_price_changes.sql`

**Extend**
1. Record active-status changes in a second audit table.
2. Build a report showing latest price changes by product.
3. Explain how to record who made a change safely.

**Done when:** your queries run on a fresh database and results match the stated business definitions.
