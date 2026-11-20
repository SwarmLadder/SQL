# 05 · Triggers and audit history

**Learn**
- Triggers can enforce or record changes close to the database.
- Keep triggers small and predictable; hidden side effects complicate debugging.

**Run:** `python tools/run_sql.py advanced/lessons/05_triggers_audit.sql`

**Practice**
1. Add a trigger that rejects a forbidden update with RAISE(ABORT, ...).
2. Log updates that change a product's active status.
3. Explain why user identity cannot be inferred from a trigger alone.

**Check:** An audit design needs retention, identity, and access controls beyond a trigger.
