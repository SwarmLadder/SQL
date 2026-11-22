# Advanced Final Assessment

Complete this after the 10 Advanced lessons, their 34 graded exercises and 4 written exercises, the three projects and the [backend lab](../backend/README.md).

## 1. Automatic check

```bash
python tools/verify_level.py advanced
```

All 50 graded exercises (34 practice, 16 interview) must pass. Bring written answers to PA02, PA12, PA16 and PA20 to your review.

## 2. Skills checklist

- [ ] I can read `EXPLAIN QUERY PLAN`, design a composite index from a query, and state its write cost.
- [ ] I can rewrite correlated subqueries as set-based aggregates and prove the results are identical.
- [ ] I can walk hierarchies with `WITH RECURSIVE`, with a depth limit and cycle protection.
- [ ] I can use transactions and savepoints, and describe what another connection sees meanwhile.
- [ ] I can make writes idempotent with unique keys, `INSERT OR IGNORE` and `ON CONFLICT DO UPDATE`.
- [ ] I can write triggers, and explain why they are not a security boundary.
- [ ] I can build summary tables and explain how and when they go stale.
- [ ] I can enforce rules with `NOT NULL`, `UNIQUE`, `CHECK` and foreign keys, and plan additive, reversible migrations.
- [ ] I can avoid `NULL` traps (`NOT IN`, `<>`, `COUNT(column)`) on purpose, not by luck.

## 3. Capstone: payments ledger hardening

Extend [Order Reconciliation](projects/01_order_reconciliation.md) into a migration plus report:

1. **Migration** (additive, reversible): an `idempotency_keys` table, a `refunds` table with constraints (positive amount, one refund per payment unless partial refunds are allowed — state your rule), and the indexes your report needs, each justified with a before/after query plan.
2. **Write path:** a script that records a payment from a webhook so that a retried delivery is a no-op and a conflicting payload is rejected.
3. **Report:** per order, items total, net paid (payments − refunds) and a flag (`ok`, `missing_payment`, `mismatch`, `over_refunded`, `unexpected_payment`).
4. **Audit:** a trigger logging changes to payment amounts, plus a paragraph on what it cannot protect against.
5. **Rollback plan** for every step.

## 4. Rubric (100 points)

| Dimension | Points | Evidence |
|---|---:|---|
| Correctness | 30 | Report flags match hand-checked cases, including retries and refunds |
| Integrity | 20 | Constraints and unique keys make invalid states impossible, not just unlikely |
| Performance | 15 | Indexes justified with plans; write costs discussed |
| Operability | 20 | Migration is additive with a rollback path; idempotent writes |
| Explanation | 15 | Clear trade-offs and limits (triggers, concurrency, staleness) |

**Readiness:** 80/100 and able to lead the [Senior backend mock round](../interview/MOCK_INTERVIEWS.md).
