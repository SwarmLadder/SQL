# Worked example I1 · ROW_NUMBER, RANK and DENSE_RANK on ties

**Problem.** "Who has the second-highest salary in each team?" The answer depends on what you do with ties.

**Run:** `python tools/run_sql.py intermediate/worked_examples/01_rank_functions.sql`

## 1. Create a tie on purpose

The script gives Fadi Ben's salary inside a transaction (rolled back at the end). Then it runs all three functions over the same window:

| full_name | salary_cents | ROW_NUMBER | RANK | DENSE_RANK |
|---|---:|---:|---:|---:|
| Ada | 12 000 000 | 1 | 1 | 1 |
| Ben | 8 500 000 | 2 | 2 | 2 |
| Fadi | 8 500 000 | 3 | 2 | 2 |

- **ROW_NUMBER** always counts 1, 2, 3. Ties get *different* numbers in an unspecified order unless you add a tie-breaker to `ORDER BY`.
- **RANK** gives ties the same number and then **skips**: the next person would be 4.
- **DENSE_RANK** gives ties the same number and **does not skip**: the next person would be 3.

## 2. Pick the function from the question

| Question | Function |
|---|---|
| "Exactly two people per team" (a page, a top-N list) | `ROW_NUMBER` + a deterministic tie-breaker |
| "Second-highest *salary*", everyone who earns it | `DENSE_RANK() = 2` |
| "Position in a competition" (1, 2, 2, 4) | `RANK` |

## 3. Filter in an outer query

Window functions are computed after `WHERE`, so `WHERE DENSE_RANK() OVER (...) = 2` is an error. Compute the rank in a CTE, then filter it. The result lists both Ben and Fadi for Engineering.

**Practise next:** [PI10](../../practice/starter/PI10.sql), [PI11](../../practice/starter/PI11.sql), [PA19](../../practice/starter/PA19.sql).
