# Intermediate Practice · 20 tasks

20 of these tasks are **graded automatically** on the course dataset and on an edge-case fixture. Each one has three hints that get more specific.

```bash
python tools/practice.py list --level intermediate
python tools/practice.py show PI01
python tools/practice.py check PI01      # grades practice/starter/PI01.sql
python tools/practice.py hint PI01 1
python tools/practice.py progress intermediate
```

<!-- exercises:start -->
| ID | Exercise | Kind | Lesson |
|---|---|---|---|
| `PI01` | [Customer lifetime totals](../../practice/starter/PI01.sql) | query | [03 cte](../../intermediate/lessons/03_cte.md) |
| `PI02` | [Items vs payments without fan-out](../../practice/starter/PI02.sql) | query | [00 multi table reports](../../intermediate/lessons/00_multi_table_reports.md) |
| `PI03` | [Above-average prices](../../practice/starter/PI03.sql) | query | [01 subqueries](../../intermediate/lessons/01_subqueries.md) |
| `PI04` | [Customers who paid](../../practice/starter/PI04.sql) | query | [02 exists](../../intermediate/lessons/02_exists.md) |
| `PI05` | [Products nobody paid for](../../practice/starter/PI05.sql) | query | [02 exists](../../intermediate/lessons/02_exists.md) |
| `PI06` | [Pending and paid](../../practice/starter/PI06.sql) | query | [08 set operations](../../intermediate/lessons/08_set_operations.md) |
| `PI07` | [Two-stage order report](../../practice/starter/PI07.sql) | query | [03 cte](../../intermediate/lessons/03_cte.md) |
| `PI08` | [Status counts in one row](../../practice/starter/PI08.sql) | query | [04 case conditional](../../intermediate/lessons/04_case_conditional.md) |
| `PI09` | [Price bands](../../practice/starter/PI09.sql) | query | [04 case conditional](../../intermediate/lessons/04_case_conditional.md) |
| `PI10` | [Salary rank within team](../../practice/starter/PI10.sql) | query | [05 windows ranking](../../intermediate/lessons/05_windows_ranking.md) |
| `PI11` | [Top two earners per team](../../practice/starter/PI11.sql) | query | [05 windows ranking](../../intermediate/lessons/05_windows_ranking.md) |
| `PI12` | [Previous order date](../../practice/starter/PI12.sql) | query | [06 windows running](../../intermediate/lessons/06_windows_running.md) |
| `PI13` | [Running revenue by month](../../practice/starter/PI13.sql) | query | [06 windows running](../../intermediate/lessons/06_windows_running.md) |
| `PI14` | [Signup month](../../practice/starter/PI14.sql) | query | [07 dates strings](../../intermediate/lessons/07_dates_strings.md) |
| `PI15` | [Orders long after signup](../../practice/starter/PI15.sql) | query | [07 dates strings](../../intermediate/lessons/07_dates_strings.md) |
| `PI16` | [UNION vs UNION ALL](../../practice/starter/PI16.sql) | query | [08 set operations](../../intermediate/lessons/08_set_operations.md) |
| `PI17` | [A reusable view](../../practice/starter/PI17.sql) | script | [09 views savepoints](../../intermediate/lessons/09_views_savepoints.md) |
| `PI18` | [Undo part of a transaction](../../practice/starter/PI18.sql) | script | [09 views savepoints](../../intermediate/lessons/09_views_savepoints.md) |
| `PI19` | [No paid order yet](../../practice/starter/PI19.sql) | query | [02 exists](../../intermediate/lessons/02_exists.md) |
| `PI20` | [Monthly revenue dashboard](../../practice/starter/PI20.sql) | query | [06 windows running](../../intermediate/lessons/06_windows_running.md) |
<!-- exercises:end -->

See [how practice works](../../practice/README.md). Stuck? Read the hints before the [worked examples](../worked_examples/README.md).
