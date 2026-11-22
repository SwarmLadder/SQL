# Level 3 — Advanced SQL and database engineering

The SQL a backend or data engineer is trusted with in production: indexes and query plans, provably-correct rewrites, recursion, transactions under concurrency, idempotent writes, triggers, summary tables, constraints and migrations, `NULL` correctness, and a finance-grade capstone.

**In numbers:** 10 lessons · 34 graded exercises + 4 written · 39 quiz questions · 6 worked examples · 3 projects · 16 interview challenges.

## Learning outcomes

By the end of this level you can:

- Read `EXPLAIN QUERY PLAN` and design composite and covering indexes from queries.
- Rewrite queries for speed and clarity, and prove equivalence on edge-case data.
- Generate sequences and walk hierarchies with `WITH RECURSIVE`, safely.
- Prevent lost updates with conditional writes and optimistic locking.
- Make writes idempotent with unique keys, `ON CONFLICT` and idempotency keys.
- Use triggers for integrity and auditing, and explain their limits.
- Build, refresh and reconcile summary tables.
- Encode business rules as constraints and change live schemas with expand/migrate/contract.
- Avoid every common `NULL` trap and test with edge-case fixtures.

## Lessons

Each lesson explains one topic in short sections, runs every example against the sample database (results are shown in the lesson), lists the most common mistakes, and ends with graded exercises, a quick quiz and a summary.

<!-- index:start -->
| # | Lesson | Time | Graded exercises | Quiz |
|---:|---|---:|---:|---:|
| 00 | [Indexes and query plans](lessons/00_indexes_explain.md) | 60 min | 2 | 4 |
| 01 | [Query rewrites and correct grain](lessons/01_query_rewrites.md) | 55 min | 4 | 4 |
| 02 | [Recursive CTEs and hierarchies](lessons/02_recursive_cte.md) | 60 min | 5 | 4 |
| 03 | [Atomic changes and savepoints](lessons/03_transactions_savepoints.md) | 60 min | 3 | 4 |
| 04 | [UPSERT and idempotency keys](lessons/04_upsert_idempotency.md) | 60 min | 5 | 4 |
| 05 | [Triggers and audit history](lessons/05_triggers_audit.md) | 55 min | 3 | 4 |
| 06 | [Summary tables and freshness](lessons/06_summary_tables.md) | 55 min | 2 | 4 |
| 07 | [Constraints and schema changes](lessons/07_constraints_migrations.md) | 60 min | 4 | 4 |
| 08 | [NULL, anti-joins, and query correctness](lessons/08_null_semantics.md) | 55 min | 3 | 4 |
| 09 | [Advanced reporting capstone](lessons/09_advanced_capstone.md) | 90 min | 3 | 3 |
<!-- index:end -->

### Units and milestones

| Unit | Lessons | Milestone |
|---|---|---|
| Performance | 00–01 | Index a hot query and prove a rewrite is equivalent |
| Hierarchies | 02 | Calendars, org charts, cycle-safe recursion |
| Safe writes | 03–04 | Transfers, optimistic locking, idempotent APIs |
| Data that maintains itself | 05–06 | Audit trail and a reconciled summary table |
| Schema and correctness | 07–08 | A reversible migration and a NULL-proof report |
| Capstone | 09 | A verified month-close report |

## Practice

- **Graded exercises** for every lesson, listed in each lesson's *Your turn* section and in [exercises/README.md](exercises/README.md). Write SQL in `practice/starter/<ID>.sql`, then run `python tools/practice.py check <ID>`. Each answer is run on the course data and an edge-case fixture; hints unlock one level at a time (`python tools/practice.py hint <ID> 1`).
- **Quick quizzes** at the end of every lesson: `python tools/quiz.py advanced/00`.
- **Interview challenges**: `python tools/interview_practice.py list --level advanced`, then the [mock interview rounds](../interview/MOCK_INTERVIEWS.md).
- **Your progress**: `python tools/practice.py progress advanced` and `python tools/verify_level.py advanced`.

## Worked examples

Six problems solved step by step (plan → wrong attempt → fix → test): [worked_examples/](worked_examples/README.md).

## Projects

Three ticket-based projects with acceptance criteria and a shared rubric: [projects/](projects/README.md).

## Suggested study plan (6 weeks, flexible)

| Week | Work |
|---|---|
| 1 | Lessons 00–01; worked example A1 |
| 2 | Lesson 02; worked examples A3, A6 |
| 3 | Lessons 03–04; worked example A4 |
| 4 | Lessons 05–06; worked example A2 |
| 5 | Lessons 07–08; worked example A5 |
| 6 | Lesson 09, interview challenges A01–A16, projects 01–03, the assessment |

**Completion standard:** every graded exercise passes (`python tools/verify_level.py advanced`), you can explain your answers out loud, your three projects meet their acceptance criteria, and you score 80+ on the [assessment](ASSESSMENT.md).

## Glossary

Every term used in this level is defined in [GLOSSARY.md](GLOSSARY.md).

## Troubleshooting

- The plan still shows `SCAN`: check column order (equality first), functions on the column, or that the table is too small to bother.
- `database is locked`: another connection holds a write transaction; keep transactions short.
- Recursion never ends: missing stop condition, or a cycle; add a visited check and a depth limit.
- An upsert double-counts on retry: recompute the group, or de-duplicate events by ID first.
- A migration fails on existing rows: validate the data before adding the constraint.

## Run

```bash
python tools/run_sql.py advanced/lessons/00_indexes_explain.sql
python tools/practice.py list --level advanced
```

## After this level

Go deeper with the [backend engineering lab](../backend/README.md), the [PostgreSQL labs](postgresql/README.md) and the [schema design interviews](../interview/schema/README.md).
