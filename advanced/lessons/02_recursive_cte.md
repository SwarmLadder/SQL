# 02 · Recursive CTEs and hierarchies

> **You will learn** how `WITH RECURSIVE` repeats a query on its own output, to generate sequences and complete calendars, to walk a hierarchy top-down and bottom-up with depth and path, and to protect recursion against cycles and runaway depth.
> **Time:** about 60 minutes · **Before this:** [Intermediate 03 · CTEs](../../intermediate/lessons/03_cte.md)

Some data is shaped like a tree: managers and reports, categories and sub-categories, comments and replies. A fixed number of self-joins can only go a fixed number of levels deep. A **recursive CTE** keeps joining until there's nothing left to find.

**Run the whole lesson:** `python tools/run_sql.py advanced/lessons/02_recursive_cte.sql`

## 1. How recursion works

A recursive CTE has two parts joined by `UNION ALL`:

1. The **anchor** (non-recursive) query produces the starting rows.
2. The **recursive** query refers to the CTE itself and produces new rows from the rows found in the *previous* step.

SQLite repeats step 2 until it produces no new rows. The simplest example is counting:

```sql
WITH RECURSIVE n(i) AS (
  SELECT 1                        -- anchor
  UNION ALL
  SELECT i + 1 FROM n WHERE i < 5 -- recursive step and stop condition
)
SELECT i FROM n;
```

<!-- result -->
| i |
|---|
| 1 |
| 2 |
| 3 |
| 4 |
| 5 |
<!-- /result -->

**Without `WHERE i < 5` this never ends.** Every recursive CTE needs a condition that eventually stops producing rows.

## 2. Generating a complete calendar

Lesson [Intermediate 06](../../intermediate/lessons/06_windows_running.md) warned that `LAG` over months with gaps compares with the wrong month. A recursive CTE generates every month, so months without sales become explicit zeros:

```sql
WITH RECURSIVE months(month_start) AS (
  SELECT '2026-01-01'
  UNION ALL
  SELECT date(month_start, '+1 month') FROM months WHERE month_start < '2026-09-01'
),
revenue AS (
  SELECT strftime('%Y-%m', paid_at) AS month, SUM(amount_cents) AS cents
  FROM payments GROUP BY month
)
SELECT strftime('%Y-%m', m.month_start) AS month,
       COALESCE(r.cents, 0) AS revenue_cents
FROM months m
LEFT JOIN revenue r ON r.month = strftime('%Y-%m', m.month_start)
ORDER BY month;
```

<!-- result -->
| month | revenue_cents |
|---|---|
| 2026-01 | 3150 |
| 2026-02 | 5400 |
| 2026-03 | 22400 |
| 2026-04 | 19600 |
| 2026-05 | 10100 |
| 2026-06 | 27500 |
| 2026-07 | 13800 |
| 2026-08 | 0 |
| 2026-09 | 0 |
<!-- /result -->

August and September show 0 instead of being missing. Now `LAG` compares true calendar neighbours.

## 3. Walking a hierarchy top-down

Start from the employees without a manager (depth 0) and repeatedly add their direct reports:

```sql
WITH RECURSIVE org(employee_id, full_name, manager_id, depth, path) AS (
  SELECT employee_id, full_name, manager_id, 0, full_name
  FROM employees
  WHERE manager_id IS NULL
  UNION ALL
  SELECT e.employee_id, e.full_name, e.manager_id, org.depth + 1,
         org.path || ' > ' || e.full_name
  FROM employees e
  JOIN org ON e.manager_id = org.employee_id
)
SELECT depth, full_name, path
FROM org
ORDER BY path;
```

<!-- result -->
| depth | full_name | path |
|---|---|---|
| 0 | Ada | Ada |
| 1 | Ben | Ada > Ben |
| 1 | Fadi | Ada > Fadi |
| 0 | Cleo | Cleo |
| 1 | Dina | Cleo > Dina |
| 1 | Hugo | Cleo > Hugo |
| 0 | Ema | Ema |
| 1 | Gina | Ema > Gina |
<!-- /result -->

- `depth` counts levels; `path` records the route from the top. Sorting by `path` prints the tree in reading order.
- Each step joins **only the rows found in the previous step** (`org` inside the recursive part means "the last batch"), not the whole result so far.

## 4. Walking bottom-up: someone's chain of command

Reverse the direction: start from one employee and follow `manager_id` upwards.

```sql
WITH RECURSIVE chain(employee_id, full_name, manager_id, level) AS (
  SELECT employee_id, full_name, manager_id, 0 FROM employees WHERE employee_id = 8
  UNION ALL
  SELECT m.employee_id, m.full_name, m.manager_id, chain.level + 1
  FROM employees m
  JOIN chain ON m.employee_id = chain.manager_id
)
SELECT level, full_name FROM chain ORDER BY level;
```

<!-- result -->
| level | full_name |
|---|---|
| 0 | Hugo |
| 1 | Cleo |
<!-- /result -->

The same pattern answers "everyone under Ada" (top-down from one person) and "total salary of Ada's organisation" (top-down, then `SUM`).

## 5. Cycles and runaway depth

Real hierarchies get corrupted: A manages B, B manages A. Recursion then never terminates. Two defences:

- **A depth limit**, so it always terminates, even if the answer is then incomplete: `WHERE org.depth < 20`.
- **A visited check**, which stops when a node is already on the path. Store IDs in the path with delimiters so `1` doesn't match `11`:

```sql
BEGIN;
UPDATE employees SET manager_id = 2 WHERE employee_id = 1;   -- Ada now reports to Ben: a cycle

WITH RECURSIVE walk(employee_id, path, depth) AS (
  SELECT 2, '/2/', 0
  UNION ALL
  SELECT e.employee_id, walk.path || e.employee_id || '/', walk.depth + 1
  FROM employees e
  JOIN walk ON e.manager_id = walk.employee_id
  WHERE instr(walk.path, '/' || e.employee_id || '/') = 0   -- not visited yet
    AND walk.depth < 20                                        -- safety net
)
SELECT employee_id, path, depth FROM walk ORDER BY depth, employee_id;

ROLLBACK;
```

<!-- result -->
*Rows changed: 1*

| employee_id | path | depth |
|---|---|---|
| 2 | /2/ | 0 |
| 1 | /2/1/ | 1 |
| 6 | /2/1/6/ | 2 |
<!-- /result -->

The walk visits Ben, Ada and Fadi once each and stops instead of looping forever. Better still, prevent cycles on write (a trigger or application check), and keep the depth limit as a safety net.

## 6. UNION vs UNION ALL in recursion

`UNION ALL` keeps every row produced; `UNION` discards rows already seen, which stops some cycles automatically, but only when the *entire row* repeats. Once a row carries a growing `depth` or `path`, it never repeats exactly, so `UNION` won't save you. Use explicit visited checks.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| No stop condition | Runs until the step limit or memory is exhausted | `WHERE` that eventually yields no rows |
| Path matching without delimiters | `1` "visited" because `11` is in the path | Delimit IDs: `/1/11/` and search for `/1/` |
| Trusting `UNION` to stop cycles | Still loops (depth makes rows unique) | Visited check + depth limit |
| Filtering depth in the final `SELECT` only | Still computes the whole tree | Put the limit in the recursive part |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PA05` | **Walk the org chart.** With WITH RECURSIVE, return employee_id, full_name, depth for every employee, where top-level managers have depth 0 and each report is one deeper than their manager. Sort by depth, then employee_id. | query |
| `PA06` | **Reporting paths with a depth limit.** Return employee_id and path, where path is the chain of names from the top manager down, joined with ' > ' (for example 'Ada > Ben'). Stop at depth 1 (top managers and their direct reports only), and guard against cycles by never revisiting a name already in the path. Sort by path. | query |
| `PA24` | **A complete calendar.** Return month (YYYY-MM) and received_cents (sum of payments by month of paid_at, 0 when none) for every month from 2026-01 to 2026-12 inclusive, sorted by month. Generate the months with WITH RECURSIVE. | query |
| `PA25` | **Ada's organisation.** Return employee_id, full_name for everyone who reports to Ada (employee 1) directly or indirectly, not including Ada, sorted by employee_id. | query |
| `PA26` | **Chain of command.** Return level, full_name for employee 8 (level 0) and each manager above them (level 1, 2, …), sorted by level. | query |

```bash
python tools/practice.py show PA05
python tools/practice.py check PA05
python tools/practice.py hint PA05 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** What are the two parts of a recursive CTE?

   - **a)** An anchor query and a recursive step joined by UNION ALL
   - **b)** Two anchors
   - **c)** A SELECT and a trigger

**2.** Why generate a calendar with a recursive CTE?

   - **a)** So months without data appear as explicit zeros
   - **b)** Dates can't be grouped otherwise
   - **c)** For speed

**3.** A path check `instr(path, '1')` is wrong because…

   - **a)** '1' also matches '11'; delimit IDs like '/1/'
   - **b)** instr doesn't exist
   - **c)** paths can't contain numbers

**4.** Does UNION (instead of UNION ALL) prevent cycles when rows carry a depth column?

   - **a)** Yes, always
   - **b)** No: depth makes every row unique
   - **c)** Only in PostgreSQL

```bash
python tools/quiz.py advanced/02 1 b      # question 1, answer b
python tools/quiz.py advanced/02           # list the questions
```
<!-- /quiz -->

## Summary

- `WITH RECURSIVE` = anchor `UNION ALL` recursive step, repeated until no new rows.
- Generate sequences and calendars to turn gaps into explicit zeros.
- Walk trees top-down (from roots via reports) or bottom-up (via `manager_id`), carrying depth and path.
- Guard against cycles with a delimited visited check and a depth limit inside the recursive part.

**Next:** [03 · Atomic changes and savepoints](03_transactions_savepoints.md)
