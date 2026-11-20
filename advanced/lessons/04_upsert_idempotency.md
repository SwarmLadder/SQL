# 04 · UPSERT and idempotency keys

**Learn**
- Unique constraints protect identity under concurrent insert attempts.
- `ON CONFLICT` chooses what to do when a unique key already exists; replay rules must also verify the payload.

**Run:** `python tools/run_sql.py advanced/lessons/04_upsert_idempotency.sql`

**Practice**
1. Demonstrate rejecting the same idempotency key with a different payload.
2. Create an inventory counter with an atomic increment on conflict.
3. Explain why `DO NOTHING` is not a complete payment-retry policy.

**Check:** Persist outcome and side effect in one transaction for reliable idempotency.
