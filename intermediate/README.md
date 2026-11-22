# Level 2 — Intermediate SQL

Reporting and analysis SQL as it's written at work: multi-table reports without fan-out, subqueries and `EXISTS`, CTE pipelines, conditional aggregation, window functions, dates, set operations, views and transactions. Every lesson builds on the Basics level.

**In numbers:** 10 lessons · 47 graded exercises · 40 quiz questions · 6 worked examples · 3 projects · 16 interview challenges.

## Learning outcomes

By the end of this level you can:

- Plan a report by grain and avoid fan-out by pre-aggregating.
- Use scalar, `IN`, derived-table and correlated subqueries, and know their `NULL` behaviour.
- Write semi- and anti-joins with `EXISTS`/`NOT EXISTS`.
- Structure long queries as named CTE stages and debug them stage by stage.
- Pivot with `SUM(CASE …)` and classify with `CASE`.
- Rank, number and compare rows with window functions; compute running totals and moving averages.
- Group and filter by dates correctly; clean and combine text.
- Combine and compare results with `UNION`, `INTERSECT`, `EXCEPT`.
- Create views and use transactions and savepoints.

## Lessons

Each lesson explains one topic in short sections, runs every example against the sample database (results are shown in the lesson), lists the most common mistakes, and ends with graded exercises, a quick quiz and a summary.

<!-- index:start -->
| # | Lesson | Time | Graded exercises | Quiz |
|---:|---|---:|---:|---:|
| 00 | [Multi-table reporting](lessons/00_multi_table_reports.md) | 50 min | 3 | 4 |
| 01 | [Scalar, IN, and derived-table subqueries](lessons/01_subqueries.md) | 50 min | 4 | 4 |
| 02 | [EXISTS and correlated subqueries](lessons/02_exists.md) | 45 min | 5 | 4 |
| 03 | [Common table expressions](lessons/03_cte.md) | 45 min | 4 | 4 |
| 04 | [CASE and conditional aggregation](lessons/04_case_conditional.md) | 45 min | 5 | 4 |
| 05 | [Window functions and rankings](lessons/05_windows_ranking.md) | 55 min | 5 | 4 |
| 06 | [LAG, LEAD, and running totals](lessons/06_windows_running.md) | 55 min | 6 | 4 |
| 07 | [Text, dates, and grouped timelines](lessons/07_dates_strings.md) | 50 min | 6 | 4 |
| 08 | [UNION, INTERSECT, EXCEPT](lessons/08_set_operations.md) | 40 min | 5 | 4 |
| 09 | [Views, savepoints, and transactions](lessons/09_views_savepoints.md) | 50 min | 4 | 4 |
<!-- index:end -->

### Units and milestones

| Unit | Lessons | Milestone |
|---|---|---|
| Reliable reports | 00, 03 | Customer report with no fan-out, as a CTE pipeline |
| Asking about related rows | 01–02 | Semi- and anti-joins without NULL traps |
| Shaping results | 04 | A pivoted monthly status report |
| Windows | 05–06 | Top-N per group, month-over-month change, running totals |
| Time and text | 07 | Quarterly and weekday timelines |
| Sets and reuse | 08–09 | Proving two queries agree; a reusable view; atomic writes |

## Practice

- **Graded exercises** for every lesson, listed in each lesson's *Your turn* section and in [exercises/README.md](exercises/README.md). Write SQL in `practice/starter/<ID>.sql`, then run `python tools/practice.py check <ID>`. Each answer is run on the course data and an edge-case fixture; hints unlock one level at a time (`python tools/practice.py hint <ID> 1`).
- **Quick quizzes** at the end of every lesson: `python tools/quiz.py intermediate/00`.
- **Interview challenges**: `python tools/interview_practice.py list --level intermediate`, then the [mock interview rounds](../interview/MOCK_INTERVIEWS.md).
- **Your progress**: `python tools/practice.py progress intermediate` and `python tools/verify_level.py intermediate`.

## Worked examples

Six problems solved step by step (plan → wrong attempt → fix → test): [worked_examples/](worked_examples/README.md).

## Projects

Three ticket-based projects with acceptance criteria and a shared rubric: [projects/](projects/README.md).

## Suggested study plan (6 weeks, flexible)

| Week | Work |
|---|---|
| 1 | Lessons 00–01; worked example I2 |
| 2 | Lessons 02–03 |
| 3 | Lessons 04–05; worked examples I1, I5 |
| 4 | Lessons 06–07; worked examples I3, I4, I6 |
| 5 | Lessons 08–09, interview challenges I01–I16 |
| 6 | Projects 01–03 and the assessment |

**Completion standard:** every graded exercise passes (`python tools/verify_level.py intermediate`), you can explain your answers out loud, your three projects meet their acceptance criteria, and you score 80+ on the [assessment](ASSESSMENT.md).

## Glossary

Every term used in this level is defined in [GLOSSARY.md](GLOSSARY.md).

## Troubleshooting

- `misuse of window function`: filter on a window result in an outer query (CTE).
- Totals too high after joining two detail tables: fan-out. Aggregate each table first.
- `NOT IN` returns nothing: the subquery contains NULL. Use `NOT EXISTS`.
- Month-over-month compares the wrong months: there are gaps; build a calendar.
- Running totals repeat on equal dates: make the window `ORDER BY` unique or use `ROWS`.

## Run

```bash
python tools/run_sql.py intermediate/lessons/00_multi_table_reports.sql
python tools/practice.py list --level intermediate
```

## Next level

Continue with the [Advanced level](../advanced/README.md) once you meet the completion standard.
