# Basics · Queries and relational foundations

Study lessons in order. Each lesson has a brief explanation, a runnable `.sql` file, and three tasks.

| # | Lesson |
|---:|---|
| 00 | [SELECT and columns](lessons/00_select.md) |
| 01 | [WHERE and NULL](lessons/01_where_null.md) |
| 02 | [Sorting and pagination](lessons/02_sort_limit.md) |
| 03 | [Expressions and types](lessons/03_expressions.md) |
| 04 | [Aggregates](lessons/04_aggregates.md) |
| 05 | [GROUP BY and HAVING](lessons/05_group_by_having.md) |
| 06 | [INNER JOIN](lessons/06_joins.md) |
| 07 | [LEFT JOIN](lessons/07_left_join.md) |
| 08 | [INSERT, UPDATE, DELETE](lessons/08_dml.md) |
| 09 | [Basics review](lessons/09_review.md) |

## Interview preparation

```bash
python tools/interview_practice.py list --level basics
```

Write answers in `interview/starter/` and check them against two datasets. See [mock interview rounds](../interview/MOCK_INTERVIEWS.md).

## Practice

- [20 exercises](exercises/README.md)
- [8 reference queries](solutions/README.md)
- [Two projects](projects/README.md)

## Run

```bash
python tools/run_sql.py basics/lessons/00_select.sql
```
