# Intermediate · Reporting and reusable query patterns

Study lessons in order. Each lesson has a brief explanation, a runnable `.sql` file, and three tasks.

| # | Lesson |
|---:|---|
| 00 | [Multi-table reports](lessons/00_multi_table_reports.md) |
| 01 | [Subqueries](lessons/01_subqueries.md) |
| 02 | [EXISTS and NOT EXISTS](lessons/02_exists.md) |
| 03 | [CTEs](lessons/03_cte.md) |
| 04 | [CASE and conditional aggregates](lessons/04_case_conditional.md) |
| 05 | [Ranking windows](lessons/05_windows_ranking.md) |
| 06 | [Running totals and LAG](lessons/06_windows_running.md) |
| 07 | [Dates and strings](lessons/07_dates_strings.md) |
| 08 | [Set operations](lessons/08_set_operations.md) |
| 09 | [Views and savepoints](lessons/09_views_savepoints.md) |

## Interview preparation

```bash
python tools/interview_practice.py list --level intermediate
```

Write answers in `interview/starter/` and check them against two datasets. See [mock interview rounds](../interview/MOCK_INTERVIEWS.md).

## Practice

- [20 graded exercises](exercises/README.md) with hints, checked on two datasets: `python tools/practice.py show PI01`
- [Worked examples](worked_examples/README.md): plan → wrong attempt → fix → test
- [8 reference queries](solutions/README.md)
- [Two projects](projects/README.md)
- [Glossary](GLOSSARY.md) · [Final assessment](ASSESSMENT.md)

## Run

```bash
python tools/run_sql.py intermediate/lessons/00_multi_table_reports.sql
```
