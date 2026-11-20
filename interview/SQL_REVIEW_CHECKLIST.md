# SQL Code Review Checklist

- Correct **business definition**: paid, refunded, active, time window?
- Correct **grain**: one row per order, customer, or item?
- JOIN keys stable; no many-to-many multiplication?
- NULLs and zero-row parents handled?
- Deterministic sort and tie-break for pagination?
- Bound parameters for all user-controlled values?
- Tenant filter applied to every read and write?
- Constraints and transactions protect concurrent updates?
- Index fits the actual filter/order; plan measured?
- Safe migrations, timeouts, connection cleanup, and slow-query metrics?

For interviews: explain one edge case, one index, and one transaction risk.
