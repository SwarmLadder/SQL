# Basics Final Assessment

Complete this after the 10 Basics lessons, the 20 graded practice exercises and the two projects.

## 1. Automatic check

```bash
python tools/verify_level.py basics
```

All 36 graded exercises (20 practice, 16 interview) must pass. This is also the [achievement](../RECOGNITION.md#track-2-achievers) requirement.

## 2. Skills checklist

- [ ] I can select, alias and de-duplicate columns, and say why `SELECT *` is risky in application code.
- [ ] I can filter with `=`, `IN`, ranges and `IS NULL`, and explain why `= NULL` never matches.
- [ ] I can sort on several keys and use `LIMIT` deterministically (with a tie-breaker).
- [ ] I can use `COUNT(*)`, `COUNT(column)`, `SUM`, `MIN`, `MAX` and `AVG`, and say which ones ignore `NULL`.
- [ ] I can group with `GROUP BY` and filter groups with `HAVING` instead of `WHERE`.
- [ ] I can write inner and left joins, including a self-join, and find unmatched rows.
- [ ] I can insert, update and delete rows safely inside a transaction, checking the affected row count.
- [ ] I store money as integer cents and can explain why.

## 3. Capstone: weekly store report

Extend [Store Sales Report](projects/01_store_sales_report.md) into one SQL file that produces, from a fresh database:

1. Paid revenue and paid order count per month.
2. The three best-selling products by units (paid orders only), with ties broken by SKU.
3. Every category with its paid revenue, **including** categories with no sales (0, not missing).
4. Customers who have orders but none of them paid.
5. A data-quality section: orders without lines, payments whose amount differs from the order's line total.

For each query, add a comment with the question it answers and one edge case you checked by hand. Then add one row inside a `BEGIN … ROLLBACK` block that would break a careless version of a query, and show that yours still gives the right answer.

## 4. Rubric (100 points)

| Dimension | Points | Evidence |
|---|---:|---|
| Correctness | 35 | Results match the questions on the course data and on your added edge row |
| Edge cases | 20 | `NULL`s, empty groups, ties and unmatched rows handled on purpose |
| Query design | 15 | Clear aliases, the right join type, aggregation at the right grain |
| Readability | 15 | Formatting, comments that state the question and assumptions |
| Safety | 15 | Writes wrapped in transactions; no reliance on row order without `ORDER BY` |

**Readiness:** aim for 80/100 and be able to explain every line out loud. That is the bar of the [Junior SQL mock round](../interview/MOCK_INTERVIEWS.md). This is a self-assessment guide, not an official certification.
