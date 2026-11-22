# Basics SQL Glossary

Terms used across the 10 Basics lessons and exercises PB01–PB20.

| Term | Definition |
|---|---|
| Aggregate function | A function that turns many rows into one value: `COUNT`, `SUM`, `MIN`, `MAX`, `AVG`. |
| Alias | A temporary name for a column (`AS customer_label`) or table (`FROM orders o`) inside one query. |
| Cardinality | How many rows match on each side of a relationship: one-to-one, one-to-many, many-to-many. |
| Column | A named, typed attribute that every row of a table has. |
| `COUNT(*)` vs `COUNT(col)` | `COUNT(*)` counts rows; `COUNT(col)` counts rows where `col` is not `NULL`. |
| DDL | Data Definition Language: statements that define structure (`CREATE`, `ALTER`, `DROP`). |
| `DISTINCT` | Removes duplicate rows from a result, comparing every selected column. |
| DML | Data Manipulation Language: statements that change rows (`INSERT`, `UPDATE`, `DELETE`). |
| Foreign key | A column whose values must exist as a key in another table, e.g. `orders.customer_id`. |
| `GROUP BY` | Splits rows into groups with equal values so aggregates are computed per group. |
| `HAVING` | Filters groups after aggregation; `WHERE` filters rows before it. |
| Inner join | Returns only row pairs that satisfy the join condition on both sides. |
| Integer cents | Storing money as whole numbers of the smallest unit to avoid floating-point rounding. |
| Left join | Returns every row of the left table, with `NULL`s where no right-hand row matches. |
| `LIMIT` / `OFFSET` | Keep at most N rows / skip the first M rows, applied after `ORDER BY`. |
| `NULL` | A marker for a missing or unknown value. Comparisons with `NULL` are unknown, not true or false. |
| `ORDER BY` | The only way to guarantee result order; without it, row order is unspecified. |
| Predicate | A condition that is true, false or unknown for each row, used in `WHERE`, `ON` and `HAVING`. |
| Primary key | The column(s) that uniquely identify a row; never `NULL`. |
| Row | One record in a table or result. |
| Schema | The set of tables, columns, types and constraints of a database. |
| Self-join | Joining a table to itself, e.g. employees to their managers. |
| Table | A named set of rows with the same columns. |
| Three-valued logic | SQL conditions can be true, false or unknown (because of `NULL`); `WHERE` keeps only true. |
| Tie-breaker | An extra `ORDER BY` key that makes the order of equal values deterministic. |
| Transaction | A group of statements that succeed or fail together (`BEGIN` … `COMMIT` / `ROLLBACK`). |
