# Intermediate Final Assessment

Complete this after the 10 Intermediate lessons, the 20 graded practice exercises and the two projects.

## 1. Automatic check

```bash
python tools/verify_level.py intermediate
```

All 36 graded exercises (20 practice, 16 interview) must pass.

## 2. Skills checklist

- [ ] I can pre-aggregate before joining to avoid fan-out, and spot a fan-out bug in someone else's query.
- [ ] I can choose between a scalar subquery, `IN`, `EXISTS` and a join, and explain the `NULL` behaviour of each.
- [ ] I can structure a report as readable CTE stages, each with a single grain.
- [ ] I can pivot with conditional aggregation (`SUM(CASE …)`).
- [ ] I can rank, number and compare rows with window functions, and pick `ROW_NUMBER`, `RANK` or `DENSE_RANK` from the question.
- [ ] I can compute running totals and period-over-period change with `SUM() OVER` and `LAG`.
- [ ] I can bucket and compare dates with `strftime` and `julianday`.
- [ ] I can explain the difference between `UNION`, `UNION ALL`, `INTERSECT` and `EXCEPT`.
- [ ] I can create a view, and use a savepoint to undo part of a transaction.

## 3. Capstone: customer activity dashboard

Extend [Customer Activity](projects/02_customer_activity.md) into a dashboard file:

1. A `customer_summary` **view**: one row per customer with lifetime paid cents, paid order count, first and last order date, and days since the last order (relative to a fixed date you state).
2. Monthly paid revenue with a running total and month-over-month change.
3. The top two customers by revenue in each signup cohort (`ROW_NUMBER`, deterministic ties).
4. A cohort table like [worked example I2](worked_examples/02_cohort_pivot.md), including customers whose only orders were cancelled.
5. A reconciliation query proving that the dashboard's grand total equals the sum of paid order lines.

## 4. Rubric (100 points)

| Dimension | Points | Evidence |
|---|---:|---|
| Correctness | 35 | Every number traces back to a checkable source query |
| Grain and fan-out | 20 | Each CTE has one stated grain; no duplicated multiplication |
| Window functions | 15 | Correct partitions, ordering and tie-breaking |
| Readability | 15 | Stage names describe content; comments state assumptions |
| Verification | 15 | Reconciliation and edge-row checks included |

**Readiness:** 80/100 and able to answer the follow-ups of the [Backend SQL mock round](../interview/MOCK_INTERVIEWS.md).
