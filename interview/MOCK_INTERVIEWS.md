# Mock Interviews — Backend SQL

Work without viewing the reference SQL. Record assumptions, SQL, tests, indexes, and trade-offs.

| Round | Time | Questions | Follow-up |
|---|---:|---|---|
| Junior SQL | 45 min | B05, B07, B09, B10 | NULLs, aggregate grain, indexes |
| Backend SQL | 60 min | I01, I03, I10, I16 | N+1, keyset vs OFFSET, query plans |
| Senior backend | 75 min | A01, A05, A12, A15 | transactions, retry/idempotency, tenancy |

**Scoring (100):** Correct results 40 · edge cases 20 · query design 15 · performance 10 · explanation 15.

Pass target: 80+. Interviewer should ask:
1. What happens with empty/missing rows?
2. Which index would you add, and how would you verify it?
3. What changes if another transaction writes concurrently?
4. How would you protect this operation from retries or tenant leaks?

Run your own answer:

```bash
python tools/interview_practice.py check A05 interview/starter/A05.sql
```

For architecture rounds, pick two cases from [Backend Scenarios](../backend/SCENARIOS.md).
