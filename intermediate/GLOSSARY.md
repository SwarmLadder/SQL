# Intermediate SQL Glossary

Terms used across the 10 Intermediate lessons and exercises PI01–PI20.

| Term | Definition |
|---|---|
| Anti-join | Keeps left rows with *no* match: `NOT EXISTS`, or `LEFT JOIN … WHERE right.key IS NULL`. |
| `CASE` | An expression that returns the value of the first `WHEN` branch that is true, else `ELSE` (or `NULL`). |
| Cohort | A group of entities sharing a starting event, e.g. customers who signed up in the same month. |
| Conditional aggregation | `SUM(CASE WHEN … THEN 1 ELSE 0 END)`: several filtered counts in one pass. |
| Correlated subquery | A subquery that refers to the current row of the outer query and is logically run once per row. |
| CTE | Common Table Expression: a named subquery introduced with `WITH`, used to build a query in stages. |
| `DENSE_RANK` | Window ranking where ties share a rank and no numbers are skipped (1, 2, 2, 3). |
| `EXCEPT` | Rows in the first query that are not in the second (duplicates removed). |
| `EXISTS` | True when the subquery returns at least one row. It never returns unknown, so it is safe with `NULL`s. |
| Fan-out | Row multiplication when joining two one-to-many relations at once, which inflates sums. |
| Frame | The subset of a window partition a window function sees, e.g. `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. |
| Grain | What one row of a result represents: per order, per customer, per month. |
| `INTERSECT` | Rows present in both queries (duplicates removed). |
| `julianday()` | SQLite function returning a fractional day number, so date differences can be subtracted. |
| `LAG` / `LEAD` | Window functions returning a value from the previous / next row of the partition. |
| Partition | The group of rows a window function is computed over (`PARTITION BY`). Rows are not collapsed. |
| Pivot | Turning row values into columns, usually with conditional aggregation. |
| `RANK` | Window ranking where ties share a rank and the following ranks are skipped (1, 2, 2, 4). |
| `ROW_NUMBER` | Window numbering 1, 2, 3 … with no ties; needs a tie-breaker to be deterministic. |
| Running total | A cumulative sum, usually `SUM(x) OVER (ORDER BY …)`. |
| Savepoint | A named point inside a transaction you can roll back to without abandoning the whole transaction. |
| Scalar subquery | A subquery returning exactly one value, usable anywhere an expression is allowed. |
| Semi-join | Keeps left rows that have at least one match, without duplicating them: `EXISTS` or `IN`. |
| `strftime()` | SQLite date formatting function, e.g. `strftime('%Y-%m', ordered_at)` for the month. |
| `UNION` / `UNION ALL` | Stack the rows of two queries; `UNION` removes duplicates, `UNION ALL` keeps them and is cheaper. |
| View | A stored, named `SELECT`. It holds no rows itself; it is recomputed when read. |
| Window function | A function computed over related rows (`OVER (…)`) that keeps every input row in the output. |
