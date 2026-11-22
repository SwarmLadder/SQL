# 08 · NULL, anti-joins, and query correctness

> **You will master** the places `NULL` changes a query's meaning (comparisons, `NOT IN`, `<>`, aggregates, `COUNT`, outer joins, `DISTINCT`, `GROUP BY` and sorting), use NULL-safe comparisons, and build a habit of testing queries against edge-case data.
> **Time:** about 55 minutes · **Before this:** [Basics 01](../../basics/lessons/01_where_null.md), [Intermediate 01](../../intermediate/lessons/01_subqueries.md) and [02](../../intermediate/lessons/02_exists.md)

Most wrong reports aren't syntax errors. They're queries that run fine and return a plausible, wrong number. `NULL` is behind a large share of them. This lesson collects every trap in one place and shows how to test for it.

**Run the whole lesson:** `python tools/run_sql.py advanced/lessons/08_null_semantics.sql`

## 1. Three-valued logic, as a table

| Expression | Result |
|---|---|
| `NULL = NULL` | unknown |
| `NULL <> 1` | unknown |
| `NULL AND false` | false |
| `NULL AND true` | unknown |
| `NULL OR true` | true |
| `NOT NULL` (the value) | unknown |
| `NULL IS NULL` | true |
| `NULL IS NOT 1` | true (NULL-safe "different") |

```sql
SELECT NULL = NULL      AS eq,
       NULL IS NULL     AS is_null,
       NULL IS NOT 1    AS null_safe_diff,
       (NULL AND 0)     AS and_false,
       (NULL OR 1)      AS or_true,
       COALESCE(NULL, 'fallback') AS coalesce_value,
       NULLIF(5, 5)     AS nullif_value;
```

<!-- result -->
| eq | is_null | null_safe_diff | and_false | or_true | coalesce_value | nullif_value |
|---|---|---|---|---|---|---|
| *NULL* | 1 | 1 | 0 | 1 | fallback | *NULL* |
<!-- /result -->

`WHERE` and `HAVING` keep only **true**. `CHECK` constraints reject only **false**, so a `CHECK (price > 0)` **accepts** a NULL price. Add `NOT NULL` if it's required.

## 2. The NOT IN trap, once more

```sql
SELECT COUNT(*) AS not_in_rows
FROM employees
WHERE employee_id NOT IN (SELECT manager_id FROM employees);
```

<!-- result -->
| not_in_rows |
|---|
| 0 |
<!-- /result -->

```sql
SELECT COUNT(*) AS not_exists_rows
FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM employees r WHERE r.manager_id = e.employee_id);
```

<!-- result -->
| not_exists_rows |
|---|
| 5 |
<!-- /result -->

`x NOT IN (a, b, NULL)` means `x <> a AND x <> b AND x <> NULL`. The last term is unknown, so the whole condition can never be true. **Default to `NOT EXISTS`.**

## 3. NULL in comparisons and filters

"Employees whose manager isn't Ada (1)" with `<>` silently drops those with no manager:

```sql
SELECT (SELECT COUNT(*) FROM employees WHERE manager_id <> 1)        AS with_not_equal,
       (SELECT COUNT(*) FROM employees WHERE manager_id IS NOT 1)    AS null_safe;
```

<!-- result -->
| with_not_equal | null_safe |
|---|---|
| 3 | 6 |
<!-- /result -->

`IS NOT` (SQLite) / `IS DISTINCT FROM` (PostgreSQL, standard SQL) treats NULL as a comparable value. Decide which meaning the question wants.

## 4. NULL in aggregates and outer joins

```sql
BEGIN;
CREATE TABLE ratings (product_id INTEGER, stars INTEGER);
INSERT INTO ratings VALUES (1, 5), (1, NULL), (1, 3), (2, NULL);

SELECT product_id,
       COUNT(*)      AS rows_total,
       COUNT(stars)  AS rated,
       AVG(stars)    AS avg_of_rated,
       SUM(stars)    AS sum_stars,
       AVG(COALESCE(stars, 0)) AS avg_treating_null_as_zero
FROM ratings
GROUP BY product_id
ORDER BY product_id;

ROLLBACK;
```

<!-- result -->
*Rows changed: 4*

| product_id | rows_total | rated | avg_of_rated | sum_stars | avg_treating_null_as_zero |
|---|---|---|---|---|---|
| 1 | 3 | 2 | 4.0 | 8 | 2.6666666666666665 |
| 2 | 1 | 0 | *NULL* | *NULL* | 0.0 |
<!-- /result -->

- `AVG` ignores NULLs: product 1's average is 4, not 2.67. Whether that's right depends on the meaning of NULL ("not rated" vs "zero stars").
- A group whose values are all NULL has `SUM` = NULL and `AVG` = NULL.
- After a `LEFT JOIN`, unmatched rows bring NULLs into aggregates, which is why lesson [Basics 07](../../basics/lessons/07_left_join.md) counted `COUNT(right.key)` and used `COALESCE`.

## 5. NULL in DISTINCT, GROUP BY, ORDER BY and UNIQUE

Here NULLs behave *as if* they were equal:

```sql
SELECT manager_id, COUNT(*) AS employees
FROM employees
GROUP BY manager_id
ORDER BY manager_id;
```

<!-- result -->
| manager_id | employees |
|---|---|
| *NULL* | 3 |
| 1 | 2 |
| 3 | 2 |
| 5 | 1 |
<!-- /result -->

- `GROUP BY` and `DISTINCT` put all NULLs in one group.
- `ORDER BY` puts NULLs first (SQLite, ascending) or last (PostgreSQL); state `NULLS LAST` when it matters.
- `UNIQUE` is the exception: it lets **many** NULLs coexist.

## 6. Test queries against an edge-case fixture

Every query in this course is graded on two datasets for a reason. Before trusting a report, run it against rows designed to break it:

| Edge case | Breaks |
|---|---|
| a parent with no children (customer without orders) | inner joins, `COUNT(*)` after left joins |
| a child of an inactive or cancelled parent | missing status filters |
| a nullable column with NULLs | `=`, `<>`, `NOT IN`, `AVG`, `CHECK` |
| ties in sort keys | `LIMIT`, `ROW_NUMBER`, pagination |
| a duplicate in a "many" table | fan-out, `SUM` without pre-aggregation |
| an empty input | `SUM` → NULL, divide by zero |
| boundary values (month end, exact thresholds) | `BETWEEN`, `<` vs `<=`, date arithmetic |

A small fixture script that inserts one row per case, inside `BEGIN … ROLLBACK`, is the cheapest test suite a SQL report can have.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| `NOT IN` over a nullable column | Zero rows | `NOT EXISTS` |
| `<>` on a nullable column | NULL rows vanish | `IS NOT` / `IS DISTINCT FROM`, or `OR col IS NULL` |
| `CHECK` without `NOT NULL` | NULLs pass the rule | Add `NOT NULL` |
| `AVG` of a column with "missing means zero" | Average too high | `AVG(COALESCE(col, 0))`, if that's what NULL means |
| Testing only with clean data | Wrong numbers in production | An edge-case fixture for every important query |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PA17` | **The NOT IN trap.** Return employee_id, full_name for employees who manage nobody, sorted by employee_id. Try NOT IN (SELECT manager_id FROM employees) first and explain to yourself why it returns no rows, then write a version that works. | query |
| `PA36` | **Not managed by Ada.** Return employee_id, full_name for employees whose manager is not employee 1, including employees who have no manager. Sort by employee_id. | query |
| `PA37` | **Average of rated products.** Start with WITH ratings(product_id, stars) AS (VALUES (1, 5), (1, NULL), (1, 3), (2, NULL), (3, 4)). Return product_id, rated (number of non-NULL ratings) and avg_stars (average of the non-NULL ratings, NULL if none) per product, sorted by product_id. | query |

```bash
python tools/practice.py show PA17
python tools/practice.py check PA17
python tools/practice.py hint PA17 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** A `CHECK (price > 0)` on a nullable column accepts a NULL price?

   - **a)** No
   - **b)** Yes: CHECK rejects only false, and NULL > 0 is unknown
   - **c)** Only in PostgreSQL

**2.** `AVG(stars)` over 5, NULL, 3 is…

   - **a)** 4
   - **b)** 2.67
   - **c)** NULL

**3.** How does GROUP BY treat NULL values?

   - **a)** Each NULL is its own group
   - **b)** All NULLs form one group
   - **c)** NULL rows are dropped

**4.** What is the cheapest way to catch NULL, tie and empty-group bugs in a report?

   - **a)** Run it against an edge-case fixture
   - **b)** Read the SQL carefully
   - **c)** Check the plan

```bash
python tools/quiz.py advanced/08 1 b      # question 1, answer b
python tools/quiz.py advanced/08           # list the questions
```
<!-- /quiz -->

## Summary

- Comparisons with NULL are unknown; `WHERE` keeps only true, `CHECK` rejects only false.
- `NOT IN` + NULL = no rows; use `NOT EXISTS`. `<>` drops NULLs; use `IS NOT` when needed.
- Aggregates ignore NULL; all-NULL groups give NULL sums and averages.
- `GROUP BY`/`DISTINCT` treat NULLs as equal; `UNIQUE` allows many.
- Test important queries against an edge-case fixture.

**Next:** [09 · Advanced reporting capstone](09_advanced_capstone.md)
