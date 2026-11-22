# Advanced Practice · 20 tasks

16 of these tasks are **graded automatically** on the course dataset and on an edge-case fixture. Each one has three hints that get more specific.

```bash
python tools/practice.py list --level advanced
python tools/practice.py show PA01
python tools/practice.py check PA01      # grades practice/starter/PA01.sql
python tools/practice.py hint PA01 1
python tools/practice.py progress advanced
```

<!-- exercises:start -->
| ID | Exercise | Kind | Lesson |
|---|---|---|---|
| `PA01` | [Index for a hot query](../../practice/starter/PA01.sql) | script | [00 indexes explain](../../advanced/lessons/00_indexes_explain.md) |
| `PA02` | The cost of indexes | written ✍️ | [00 indexes explain](../../advanced/lessons/00_indexes_explain.md) |
| `PA03` | [EXISTS rewritten as a JOIN](../../practice/starter/PA03.sql) | query | [01 query rewrites](../../advanced/lessons/01_query_rewrites.md) |
| `PA04` | [Correlated subquery to aggregate CTE](../../practice/starter/PA04.sql) | query | [01 query rewrites](../../advanced/lessons/01_query_rewrites.md) |
| `PA05` | [Walk the org chart](../../practice/starter/PA05.sql) | query | [02 recursive cte](../../advanced/lessons/02_recursive_cte.md) |
| `PA06` | [Reporting paths with a depth limit](../../practice/starter/PA06.sql) | query | [02 recursive cte](../../advanced/lessons/02_recursive_cte.md) |
| `PA07` | [Roll back two updates](../../practice/starter/PA07.sql) | script | [03 transactions savepoints](../../advanced/lessons/03_transactions_savepoints.md) |
| `PA08` | [Idempotency keys](../../practice/starter/PA08.sql) | script | [04 upsert idempotency](../../advanced/lessons/04_upsert_idempotency.md) |
| `PA09` | [UPSERT a counter](../../practice/starter/PA09.sql) | script | [04 upsert idempotency](../../advanced/lessons/04_upsert_idempotency.md) |
| `PA10` | [Replay or conflict?](../../practice/starter/PA10.sql) | query | [04 upsert idempotency](../../advanced/lessons/04_upsert_idempotency.md) |
| `PA11` | [Price change log](../../practice/starter/PA11.sql) | script | [05 triggers audit](../../advanced/lessons/05_triggers_audit.md) |
| `PA12` | Why triggers are not audit security | written ✍️ | [05 triggers audit](../../advanced/lessons/05_triggers_audit.md) |
| `PA13` | [Snapshot that goes stale](../../practice/starter/PA13.sql) | script | [06 summary tables](../../advanced/lessons/06_summary_tables.md) |
| `PA14` | [Constraints that reject bad data](../../practice/starter/PA14.sql) | script | [07 constraints migrations](../../advanced/lessons/07_constraints_migrations.md) |
| `PA15` | [Additive migration](../../practice/starter/PA15.sql) | script | [07 constraints migrations](../../advanced/lessons/07_constraints_migrations.md) |
| `PA16` | Plan a zero-downtime migration | written ✍️ | [07 constraints migrations](../../advanced/lessons/07_constraints_migrations.md) |
| `PA17` | [The NOT IN trap](../../practice/starter/PA17.sql) | query | [08 null semantics](../../advanced/lessons/08_null_semantics.md) |
| `PA18` | [Order-to-payment reconciliation](../../practice/starter/PA18.sql) | query | [09 advanced capstone](../../advanced/lessons/09_advanced_capstone.md) |
| `PA19` | [Top customers with DENSE_RANK](../../practice/starter/PA19.sql) | query | [09 advanced capstone](../../advanced/lessons/09_advanced_capstone.md) |
| `PA20` | Revenue report checklist | written ✍️ | [09 advanced capstone](../../advanced/lessons/09_advanced_capstone.md) |
<!-- exercises:end -->

## Written tasks

These have no automatic grade. Answer them in your notes, in a study group, or in your achievement PR description.

- **PA02 · The cost of indexes.** Every index speeds up some reads and slows down every write to its table. For the index you created in PA01, list which statements get slower, estimate the storage cost, and describe how you would decide whether to keep it in production.
- **PA12 · Why triggers are not audit security.** Your price_changes trigger records changes made through normal UPDATE statements. List at least three ways a change could happen without a trustworthy log entry (think about who can drop triggers, edit the log table, or write outside the database), and what you would add to make the audit trail reliable.
- **PA16 · Plan a zero-downtime migration.** You must rename customers.city to customers.city_name while two versions of the application run at once. Write the expand/migrate/contract steps, what each application version reads and writes during each step, and how you would roll back at every point.
- **PA20 · Revenue report checklist.** Write the checklist you would run before trusting a monthly revenue report: which statuses count, refunds and partial payments, time zones and month boundaries, join fan-out, NULLs, currency units, and how you would cross-check the total against an independent source.

See [how practice works](../../practice/README.md). Stuck? Read the hints before the [worked examples](../worked_examples/README.md).
