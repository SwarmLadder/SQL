# Intermediate Practice · 47 tasks

47 of these tasks are **graded automatically** on the course dataset and on an edge-case fixture. Each one has three hints that get more specific.

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
| `PI21` | [Lines and payments per order](../../practice/starter/PI21.sql) | query | [00 multi table reports](../../intermediate/lessons/00_multi_table_reports.md) |
| `PI22` | [Paid orders that don't add up](../../practice/starter/PI22.sql) | query | [00 multi table reports](../../intermediate/lessons/00_multi_table_reports.md) |
| `PI23` | [Above their team's average](../../practice/starter/PI23.sql) | query | [01 subqueries](../../intermediate/lessons/01_subqueries.md) |
| `PI24` | [Products sold in paid orders](../../practice/starter/PI24.sql) | query | [01 subqueries](../../intermediate/lessons/01_subqueries.md) |
| `PI25` | [Bigger teams](../../practice/starter/PI25.sql) | query | [01 subqueries](../../intermediate/lessons/01_subqueries.md) |
| `PI26` | [Teams without employees](../../practice/starter/PI26.sql) | query | [02 exists](../../intermediate/lessons/02_exists.md) |
| `PI27` | [Quick first orders](../../practice/starter/PI27.sql) | query | [02 exists](../../intermediate/lessons/02_exists.md) |
| `PI28` | [Months above average](../../practice/starter/PI28.sql) | query | [03 cte](../../intermediate/lessons/03_cte.md) |
| `PI29` | [Big spenders](../../practice/starter/PI29.sql) | query | [03 cte](../../intermediate/lessons/03_cte.md) |
| `PI30` | [Payment method pivot](../../practice/starter/PI30.sql) | query | [04 case conditional](../../intermediate/lessons/04_case_conditional.md) |
| `PI31` | [High earners per team](../../practice/starter/PI31.sql) | query | [04 case conditional](../../intermediate/lessons/04_case_conditional.md) |
| `PI32` | [Work queue order](../../practice/starter/PI32.sql) | query | [04 case conditional](../../intermediate/lessons/04_case_conditional.md) |
| `PI33` | [Share of revenue](../../practice/starter/PI33.sql) | query | [05 windows ranking](../../intermediate/lessons/05_windows_ranking.md) |
| `PI34` | [Second-highest salary per team](../../practice/starter/PI34.sql) | query | [05 windows ranking](../../intermediate/lessons/05_windows_ranking.md) |
| `PI35` | [Priciest product per category](../../practice/starter/PI35.sql) | query | [05 windows ranking](../../intermediate/lessons/05_windows_ranking.md) |
| `PI36` | [Days since the previous order](../../practice/starter/PI36.sql) | query | [06 windows running](../../intermediate/lessons/06_windows_running.md) |
| `PI37` | [Running spend per customer](../../practice/starter/PI37.sql) | query | [06 windows running](../../intermediate/lessons/06_windows_running.md) |
| `PI38` | [Three-month moving average](../../practice/starter/PI38.sql) | query | [06 windows running](../../intermediate/lessons/06_windows_running.md) |
| `PI39` | [Orders per quarter](../../practice/starter/PI39.sql) | query | [07 dates strings](../../intermediate/lessons/07_dates_strings.md) |
| `PI40` | [Orders by weekday](../../practice/starter/PI40.sql) | query | [07 dates strings](../../intermediate/lessons/07_dates_strings.md) |
| `PI41` | [Orders in June](../../practice/starter/PI41.sql) | query | [07 dates strings](../../intermediate/lessons/07_dates_strings.md) |
| `PI42` | [Email local parts](../../practice/starter/PI42.sql) | query | [07 dates strings](../../intermediate/lessons/07_dates_strings.md) |
| `PI43` | [Pending or paid by transfer](../../practice/starter/PI43.sql) | query | [08 set operations](../../intermediate/lessons/08_set_operations.md) |
| `PI44` | [Products in pending and paid orders](../../practice/starter/PI44.sql) | query | [08 set operations](../../intermediate/lessons/08_set_operations.md) |
| `PI45` | [Ordered but never paid](../../practice/starter/PI45.sql) | query | [08 set operations](../../intermediate/lessons/08_set_operations.md) |
| `PI46` | [Monthly revenue view](../../practice/starter/PI46.sql) | script | [09 views savepoints](../../intermediate/lessons/09_views_savepoints.md) |
| `PI47` | [Record a sale atomically](../../practice/starter/PI47.sql) | script | [09 views savepoints](../../intermediate/lessons/09_views_savepoints.md) |
<!-- exercises:end -->

See [how practice works](../../practice/README.md). Stuck? Read the hints before the [worked examples](../worked_examples/README.md).
