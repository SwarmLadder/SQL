# Graded practice

56 graded SQL exercises plus 4 written ones, one set per level, tied to the lessons. Each graded exercise:

- has a **precise prompt**: columns, filters and sort order are specified, so there is one correct result;
- runs your SQL on **two datasets**: the course data and an edge-case fixture (an extra customer with no orders, an unordered product, a product only bought in a cancelled order, a short payment, a new team member...). A query that only works on the visible data fails the second run;
- reports **what differs** (row count, order, column names, the first wrong row, a rejected constraint), never the reference answer;
- has **three hints**, from a nudge to almost-syntax. Ask for them one at a time.

## Workflow

```bash
python tools/practice.py list --level basics     # what's there
python tools/practice.py show PB05               # read the task
# edit practice/starter/PB05.sql
python tools/practice.py check PB05              # ✅ or ❌ with a reason
python tools/practice.py hint PB05 1             # 1 = gentle ... 3 = most specific
python tools/practice.py progress basics         # your whole level at a glance
python tools/verify_level.py basics              # practice + interview: the whole level
```

Everything runs locally with Python 3.10+ and the standard-library `sqlite3`. Each run uses a fresh in-memory database, so you can't damage the dataset.

## Exercise kinds

| Kind | You write | The checker compares |
|---|---|---|
| **query** | One read-only `SELECT` or `WITH ... SELECT` | Your rows (and, where the prompt says so, column names) with the reference, on both datasets |
| **script** | Any SQL: `CREATE`, `INSERT`, `UPDATE`, transactions, triggers, indexes | It runs your script, then fixed **probe** statements (e.g. inserts that a constraint must reject), then **verify** queries, and sometimes the **query plan**. Every outcome must match the reference |
| **written** ✍️ | Prose | Nothing automatic: discuss it with a reviewer or study group |

Script exercises must leave no transaction open. Learners control `BEGIN`, `SAVEPOINT` and `COMMIT` themselves.

## Finish a level

A level is complete when every graded practice exercise **and** every interview challenge of it passes: `python tools/verify_level.py <level>`.

`practice/answers/` holds the reference answers so maintainers can keep the checker correct. Solve first; compare afterwards.

## All exercises

<!-- exercises:start -->
### Basics

| ID | Exercise | Kind | Lesson |
|---|---|---|---|
| `PB01` | [Active catalog](../practice/starter/PB01.sql) | query | [00 select](../basics/lessons/00_select.md) |
| `PB02` | [Customer labels](../practice/starter/PB02.sql) | query | [00 select](../basics/lessons/00_select.md) |
| `PB03` | [Distinct order statuses](../practice/starter/PB03.sql) | query | [00 select](../basics/lessons/00_select.md) |
| `PB04` | [Cheap products](../practice/starter/PB04.sql) | query | [01 where null](../basics/lessons/01_where_null.md) |
| `PB05` | [Orders needing attention](../practice/starter/PB05.sql) | query | [01 where null](../basics/lessons/01_where_null.md) |
| `PB06` | [Top of the org chart](../practice/starter/PB06.sql) | query | [01 where null](../basics/lessons/01_where_null.md) |
| `PB07` | [Latest three orders](../practice/starter/PB07.sql) | query | [02 sort limit](../basics/lessons/02_sort_limit.md) |
| `PB08` | [Premium shelf](../practice/starter/PB08.sql) | query | [02 sort limit](../basics/lessons/02_sort_limit.md) |
| `PB09` | [Product labels](../practice/starter/PB09.sql) | query | [03 expressions](../basics/lessons/03_expressions.md) |
| `PB10` | [Catalog size](../practice/starter/PB10.sql) | query | [04 aggregates](../basics/lessons/04_aggregates.md) |
| `PB11` | [Units sold](../practice/starter/PB11.sql) | query | [04 aggregates](../basics/lessons/04_aggregates.md) |
| `PB12` | [Active price range](../practice/starter/PB12.sql) | query | [04 aggregates](../basics/lessons/04_aggregates.md) |
| `PB13` | [Orders by status](../practice/starter/PB13.sql) | query | [05 group by having](../basics/lessons/05_group_by_having.md) |
| `PB14` | [Repeat customers](../practice/starter/PB14.sql) | query | [05 group by having](../basics/lessons/05_group_by_having.md) |
| `PB15` | [Revenue by payment method](../practice/starter/PB15.sql) | query | [05 group by having](../basics/lessons/05_group_by_having.md) |
| `PB16` | [Products with categories](../practice/starter/PB16.sql) | query | [06 joins](../basics/lessons/06_joins.md) |
| `PB17` | [Who placed each order](../practice/starter/PB17.sql) | query | [06 joins](../basics/lessons/06_joins.md) |
| `PB18` | [Employees and managers](../practice/starter/PB18.sql) | query | [07 left join](../basics/lessons/07_left_join.md) |
| `PB19` | [Never ordered](../practice/starter/PB19.sql) | query | [07 left join](../basics/lessons/07_left_join.md) |
| `PB20` | [Paid order summary](../practice/starter/PB20.sql) | query | [09 review](../basics/lessons/09_review.md) |

### Intermediate

| ID | Exercise | Kind | Lesson |
|---|---|---|---|
| `PI01` | [Customer lifetime totals](../practice/starter/PI01.sql) | query | [03 cte](../intermediate/lessons/03_cte.md) |
| `PI02` | [Items vs payments without fan-out](../practice/starter/PI02.sql) | query | [00 multi table reports](../intermediate/lessons/00_multi_table_reports.md) |
| `PI03` | [Above-average prices](../practice/starter/PI03.sql) | query | [01 subqueries](../intermediate/lessons/01_subqueries.md) |
| `PI04` | [Customers who paid](../practice/starter/PI04.sql) | query | [02 exists](../intermediate/lessons/02_exists.md) |
| `PI05` | [Products nobody paid for](../practice/starter/PI05.sql) | query | [02 exists](../intermediate/lessons/02_exists.md) |
| `PI06` | [Pending and paid](../practice/starter/PI06.sql) | query | [08 set operations](../intermediate/lessons/08_set_operations.md) |
| `PI07` | [Two-stage order report](../practice/starter/PI07.sql) | query | [03 cte](../intermediate/lessons/03_cte.md) |
| `PI08` | [Status counts in one row](../practice/starter/PI08.sql) | query | [04 case conditional](../intermediate/lessons/04_case_conditional.md) |
| `PI09` | [Price bands](../practice/starter/PI09.sql) | query | [04 case conditional](../intermediate/lessons/04_case_conditional.md) |
| `PI10` | [Salary rank within team](../practice/starter/PI10.sql) | query | [05 windows ranking](../intermediate/lessons/05_windows_ranking.md) |
| `PI11` | [Top two earners per team](../practice/starter/PI11.sql) | query | [05 windows ranking](../intermediate/lessons/05_windows_ranking.md) |
| `PI12` | [Previous order date](../practice/starter/PI12.sql) | query | [06 windows running](../intermediate/lessons/06_windows_running.md) |
| `PI13` | [Running revenue by month](../practice/starter/PI13.sql) | query | [06 windows running](../intermediate/lessons/06_windows_running.md) |
| `PI14` | [Signup month](../practice/starter/PI14.sql) | query | [07 dates strings](../intermediate/lessons/07_dates_strings.md) |
| `PI15` | [Orders long after signup](../practice/starter/PI15.sql) | query | [07 dates strings](../intermediate/lessons/07_dates_strings.md) |
| `PI16` | [UNION vs UNION ALL](../practice/starter/PI16.sql) | query | [08 set operations](../intermediate/lessons/08_set_operations.md) |
| `PI17` | [A reusable view](../practice/starter/PI17.sql) | script | [09 views savepoints](../intermediate/lessons/09_views_savepoints.md) |
| `PI18` | [Undo part of a transaction](../practice/starter/PI18.sql) | script | [09 views savepoints](../intermediate/lessons/09_views_savepoints.md) |
| `PI19` | [No paid order yet](../practice/starter/PI19.sql) | query | [02 exists](../intermediate/lessons/02_exists.md) |
| `PI20` | [Monthly revenue dashboard](../practice/starter/PI20.sql) | query | [06 windows running](../intermediate/lessons/06_windows_running.md) |

### Advanced

| ID | Exercise | Kind | Lesson |
|---|---|---|---|
| `PA01` | [Index for a hot query](../practice/starter/PA01.sql) | script | [00 indexes explain](../advanced/lessons/00_indexes_explain.md) |
| `PA02` | The cost of indexes | written ✍️ | [00 indexes explain](../advanced/lessons/00_indexes_explain.md) |
| `PA03` | [EXISTS rewritten as a JOIN](../practice/starter/PA03.sql) | query | [01 query rewrites](../advanced/lessons/01_query_rewrites.md) |
| `PA04` | [Correlated subquery to aggregate CTE](../practice/starter/PA04.sql) | query | [01 query rewrites](../advanced/lessons/01_query_rewrites.md) |
| `PA05` | [Walk the org chart](../practice/starter/PA05.sql) | query | [02 recursive cte](../advanced/lessons/02_recursive_cte.md) |
| `PA06` | [Reporting paths with a depth limit](../practice/starter/PA06.sql) | query | [02 recursive cte](../advanced/lessons/02_recursive_cte.md) |
| `PA07` | [Roll back two updates](../practice/starter/PA07.sql) | script | [03 transactions savepoints](../advanced/lessons/03_transactions_savepoints.md) |
| `PA08` | [Idempotency keys](../practice/starter/PA08.sql) | script | [04 upsert idempotency](../advanced/lessons/04_upsert_idempotency.md) |
| `PA09` | [UPSERT a counter](../practice/starter/PA09.sql) | script | [04 upsert idempotency](../advanced/lessons/04_upsert_idempotency.md) |
| `PA10` | [Replay or conflict?](../practice/starter/PA10.sql) | query | [04 upsert idempotency](../advanced/lessons/04_upsert_idempotency.md) |
| `PA11` | [Price change log](../practice/starter/PA11.sql) | script | [05 triggers audit](../advanced/lessons/05_triggers_audit.md) |
| `PA12` | Why triggers are not audit security | written ✍️ | [05 triggers audit](../advanced/lessons/05_triggers_audit.md) |
| `PA13` | [Snapshot that goes stale](../practice/starter/PA13.sql) | script | [06 summary tables](../advanced/lessons/06_summary_tables.md) |
| `PA14` | [Constraints that reject bad data](../practice/starter/PA14.sql) | script | [07 constraints migrations](../advanced/lessons/07_constraints_migrations.md) |
| `PA15` | [Additive migration](../practice/starter/PA15.sql) | script | [07 constraints migrations](../advanced/lessons/07_constraints_migrations.md) |
| `PA16` | Plan a zero-downtime migration | written ✍️ | [07 constraints migrations](../advanced/lessons/07_constraints_migrations.md) |
| `PA17` | [The NOT IN trap](../practice/starter/PA17.sql) | query | [08 null semantics](../advanced/lessons/08_null_semantics.md) |
| `PA18` | [Order-to-payment reconciliation](../practice/starter/PA18.sql) | query | [09 advanced capstone](../advanced/lessons/09_advanced_capstone.md) |
| `PA19` | [Top customers with DENSE_RANK](../practice/starter/PA19.sql) | query | [09 advanced capstone](../advanced/lessons/09_advanced_capstone.md) |
| `PA20` | Revenue report checklist | written ✍️ | [09 advanced capstone](../advanced/lessons/09_advanced_capstone.md) |
<!-- exercises:end -->
