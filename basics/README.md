# Level 1 — SQL Basics

A complete beginner course in reading and changing relational data. Ten lessons teach one topic each, run every example on a real (fictional) shop database, and test it straight away with graded exercises and a quiz. No prior SQL is expected.

**In numbers:** 10 lessons · 58 graded exercises · 39 quiz questions · 6 worked examples · 3 projects · 16 interview challenges.

## Learning outcomes

By the end of this level you can:

- Read a schema and explain tables, rows, columns, primary and foreign keys.
- Select, filter, sort and page through data, including correct handling of `NULL`.
- Compute values with expressions and keep money exact in integer cents.
- Summarise data with aggregates and `GROUP BY`/`HAVING`, and name the grain of a result.
- Combine tables with inner and left joins, and find missing data with anti-joins.
- Insert, update and delete safely inside transactions.
- Build and cross-check a small business report.

## Lessons

Each lesson explains one topic in short sections, runs every example against the sample database (results are shown in the lesson), lists the most common mistakes, and ends with graded exercises, a quick quiz and a summary.

<!-- index:start -->
| # | Lesson | Time | Graded exercises | Quiz |
|---:|---|---:|---:|---:|
| 00 | [SELECT and columns](lessons/00_select.md) | 35 min | 6 | 4 |
| 01 | [WHERE, comparisons, and NULL](lessons/01_where_null.md) | 45 min | 6 | 4 |
| 02 | [ORDER BY and LIMIT](lessons/02_sort_limit.md) | 35 min | 6 | 4 |
| 03 | [Types and expressions](lessons/03_expressions.md) | 45 min | 6 | 4 |
| 04 | [COUNT, SUM, MIN, MAX, AVG](lessons/04_aggregates.md) | 40 min | 6 | 4 |
| 05 | [GROUP BY and HAVING](lessons/05_group_by_having.md) | 45 min | 6 | 4 |
| 06 | [INNER JOIN relationships](lessons/06_joins.md) | 50 min | 6 | 4 |
| 07 | [LEFT JOIN and missing data](lessons/07_left_join.md) | 45 min | 5 | 4 |
| 08 | [INSERT, UPDATE, DELETE](lessons/08_dml.md) | 50 min | 5 | 4 |
| 09 | [Basics review: order report](lessons/09_review.md) | 60 min | 6 | 3 |
<!-- index:end -->

### Units and milestones

| Unit | Lessons | Milestone |
|---|---|---|
| Reading data | 00–02 | Write a filtered, sorted, paginated product list |
| Computing | 03–04 | Produce exact money totals and counts |
| Summaries | 05 | A per-month, per-status report |
| Relationships | 06–07 | Join orders, customers and products; find what's missing |
| Changing data | 08 | A safe, transactional catalog update |
| Putting it together | 09 | A verified sales report for the owner |

## Practice

- **Graded exercises** for every lesson, listed in each lesson's *Your turn* section and in [exercises/README.md](exercises/README.md). Write SQL in `practice/starter/<ID>.sql`, then run `python tools/practice.py check <ID>`. Each answer is run on the course data and an edge-case fixture; hints unlock one level at a time (`python tools/practice.py hint <ID> 1`).
- **Quick quizzes** at the end of every lesson: `python tools/quiz.py basics/00`.
- **Interview challenges**: `python tools/interview_practice.py list --level basics`, then the [mock interview rounds](../interview/MOCK_INTERVIEWS.md).
- **Your progress**: `python tools/practice.py progress basics` and `python tools/verify_level.py basics`.

## Worked examples

Six problems solved step by step (plan → wrong attempt → fix → test): [worked_examples/](worked_examples/README.md).

## Projects

Three ticket-based projects with acceptance criteria and a shared rubric: [projects/](projects/README.md).

## Suggested study plan (6 weeks, flexible)

| Week | Work |
|---|---|
| 1 | Lessons 00–02, their exercises and quizzes |
| 2 | Lessons 03–04; worked examples B4 |
| 3 | Lessons 05–06; worked examples B1, B3, B5 |
| 4 | Lessons 07–08; worked examples B2, B6 |
| 5 | Lesson 09, interview challenges B01–B16 |
| 6 | Projects 01–03 and the assessment |

**Completion standard:** every graded exercise passes (`python tools/verify_level.py basics`), you can explain your answers out loud, your three projects meet their acceptance criteria, and you score 80+ on the [assessment](ASSESSMENT.md).

## Glossary

Every term used in this level is defined in [GLOSSARY.md](GLOSSARY.md).

## Troubleshooting

- `no such column`: check the spelling and which table the column lives in (`SELECT * FROM t LIMIT 1` shows the columns).
- `ambiguous column name`: two joined tables share the name; prefix it with the table alias.
- A query returns nothing: look for `= NULL`, a status filter in the wrong place, or an inner join that should be a left join.
- Numbers look doubled: you joined a one-to-many table and counted lines instead of orders.
- `Incomplete SQL statement`: end every statement with a semicolon.

## Run

```bash
python tools/run_sql.py basics/lessons/00_select.sql
python tools/practice.py list --level basics
```

## Next level

Continue with the [Intermediate level](../intermediate/README.md) once you meet the completion standard.
