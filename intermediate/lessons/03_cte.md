# 03 · Common table expressions

**Learn**
- `WITH name AS (...)` gives a query step a readable name.
- CTEs help isolate business logic; they do not automatically guarantee faster execution.

**Run:** `python tools/run_sql.py intermediate/lessons/03_cte.sql`

**Practice**
1. Use two CTEs to show monthly paid sales in cents.
2. Explain what happens if the same CTE name is used twice.
3. Refactor a nested subquery into named CTE stages.

**Check:** A CTE is typically scoped to one SQL statement.
