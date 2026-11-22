# 05 · Window functions and rankings

> **You will learn** to compute values across related rows **without collapsing them** using `OVER (…)`, to restart a calculation per group with `PARTITION BY`, to rank with `ROW_NUMBER`, `RANK` and `DENSE_RANK`, and to solve "top N per group".
> **Time:** about 55 minutes · **Before this:** [03 · Common table expressions](03_cte.md)

`GROUP BY` answers "what is each team's average salary?" but loses the individual employees. A **window function** answers "what is each employee's salary *and* their team's average?" Every input row stays in the output, with extra values computed over a *window* of related rows.

**Run the whole lesson:** `python tools/run_sql.py intermediate/lessons/05_windows_ranking.sql`

## 1. Aggregates over a window

Add `OVER (…)` to an aggregate and it stops collapsing rows:

```sql
SELECT full_name, team_id, salary_cents,
       ROUND(AVG(salary_cents) OVER (PARTITION BY team_id)) AS team_avg,
       ROUND(salary_cents - AVG(salary_cents) OVER (PARTITION BY team_id)) AS diff_from_team_avg,
       COUNT(*) OVER () AS all_staff
FROM employees
ORDER BY team_id, salary_cents DESC;
```

<!-- result -->
| full_name | team_id | salary_cents | team_avg | diff_from_team_avg | all_staff |
|---|---|---|---|---|---|
| Ada | 1 | 12000000 | 9333333.0 | 2666667.0 | 8 |
| Ben | 1 | 8500000 | 9333333.0 | -833333.0 | 8 |
| Fadi | 1 | 7500000 | 9333333.0 | -1833333.0 | 8 |
| Cleo | 2 | 9500000 | 7766667.0 | 1733333.0 | 8 |
| Dina | 2 | 7000000 | 7766667.0 | -766667.0 | 8 |
| Hugo | 2 | 6800000 | 7766667.0 | -966667.0 | 8 |
| Ema | 3 | 6500000 | 5750000.0 | 750000.0 | 8 |
| Gina | 3 | 5000000 | 5750000.0 | -750000.0 | 8 |
<!-- /result -->

- `PARTITION BY team_id` splits rows into groups, like `GROUP BY`, but each row keeps its identity.
- `OVER ()` with nothing inside means *the whole result* is one window.
- Window functions run **after** `WHERE`, `GROUP BY` and `HAVING`. They see the rows that survived those steps.

## 2. Numbering and ranking

Ranking functions need an order *inside* the window:

```sql
SELECT full_name, team_id, salary_cents,
       ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY salary_cents DESC) AS row_num
FROM employees
ORDER BY team_id, row_num;
```

<!-- result -->
| full_name | team_id | salary_cents | row_num |
|---|---|---|---|
| Ada | 1 | 12000000 | 1 |
| Ben | 1 | 8500000 | 2 |
| Fadi | 1 | 7500000 | 3 |
| Cleo | 2 | 9500000 | 1 |
| Dina | 2 | 7000000 | 2 |
| Hugo | 2 | 6800000 | 3 |
| Ema | 3 | 6500000 | 1 |
| Gina | 3 | 5000000 | 2 |
<!-- /result -->

The three ranking functions differ only on **ties**. Create a tie (Fadi gets Ben's salary) and compare:

```sql
BEGIN;
UPDATE employees SET salary_cents = 8500000 WHERE employee_id = 6;

SELECT full_name, salary_cents,
       ROW_NUMBER() OVER w AS row_number,
       RANK()       OVER w AS rank,
       DENSE_RANK() OVER w AS dense_rank
FROM employees
WINDOW w AS (ORDER BY salary_cents DESC)
ORDER BY salary_cents DESC, full_name;

ROLLBACK;
```

<!-- result -->
*Rows changed: 1*

| full_name | salary_cents | row_number | rank | dense_rank |
|---|---|---|---|---|
| Ada | 12000000 | 1 | 1 | 1 |
| Cleo | 9500000 | 2 | 2 | 2 |
| Ben | 8500000 | 3 | 3 | 3 |
| Fadi | 8500000 | 4 | 3 | 3 |
| Dina | 7000000 | 5 | 5 | 4 |
| Hugo | 6800000 | 6 | 6 | 5 |
| Ema | 6500000 | 7 | 7 | 6 |
| Gina | 5000000 | 8 | 8 | 7 |
<!-- /result -->

| Function | Ties | After a tie | Use when |
|---|---|---|---|
| `ROW_NUMBER()` | different numbers (arbitrary unless you add a tie-breaker) | continues 1, 2, 3 | you need exactly N rows |
| `RANK()` | same number | skips (1, 2, 2, 4) | competition ranking |
| `DENSE_RANK()` | same number | no gap (1, 2, 2, 3) | "the 2nd-highest value" |

`WINDOW w AS (…)` names a window definition so several functions can share it.

## 3. Top N per group

"The two highest-paid people in each team" is the classic window problem. You can't filter on a window function in the same `SELECT`'s `WHERE`, because `WHERE` runs before windows are computed. Compute the number in a CTE and filter outside:

```sql
WITH ranked AS (
  SELECT e.employee_id, e.full_name, e.team_id, e.salary_cents,
         ROW_NUMBER() OVER (PARTITION BY e.team_id
                            ORDER BY e.salary_cents DESC, e.employee_id) AS rn
  FROM employees e
)
SELECT t.team_name, r.full_name, r.salary_cents
FROM ranked r
JOIN teams t ON t.team_id = r.team_id
WHERE r.rn <= 2
ORDER BY t.team_name, r.rn;
```

<!-- result -->
| team_name | full_name | salary_cents |
|---|---|---|
| Engineering | Ada | 12000000 |
| Engineering | Ben | 8500000 |
| Sales | Cleo | 9500000 |
| Sales | Dina | 7000000 |
| Support | Ema | 6500000 |
| Support | Gina | 5000000 |
<!-- /result -->

The tie-breaker `e.employee_id` makes the result deterministic. Without it, two equal salaries could swap places between runs.

## 4. Ranking aggregated values

Windows run after `GROUP BY`, so you can rank groups. Customers ranked by paid revenue, with each one's share of the total:

```sql
WITH revenue AS (
  SELECT o.customer_id, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM orders o
  JOIN order_items i ON i.order_id = o.order_id
  WHERE o.status = 'paid'
  GROUP BY o.customer_id
)
SELECT customer_id, revenue_cents,
       DENSE_RANK() OVER (ORDER BY revenue_cents DESC) AS revenue_rank,
       ROUND(100.0 * revenue_cents / SUM(revenue_cents) OVER (), 1) AS pct_of_total
FROM revenue
ORDER BY revenue_rank, customer_id;
```

<!-- result -->
| customer_id | revenue_cents | revenue_rank | pct_of_total |
|---|---|---|---|
| 1 | 25550 | 1 | 25.1 |
| 4 | 19600 | 2 | 19.2 |
| 8 | 16150 | 3 | 15.8 |
| 3 | 13800 | 4 | 13.5 |
| 7 | 11350 | 5 | 11.1 |
| 6 | 10100 | 6 | 9.9 |
| 2 | 5400 | 7 | 5.3 |
<!-- /result -->

`SUM(revenue_cents) OVER ()` is the grand total repeated on every row, which is exactly what a share calculation needs. Note the `100.0` to force real division.

## 5. NTILE and percentiles

`NTILE(n)` splits ordered rows into *n* roughly equal buckets, which is useful for quartiles:

```sql
SELECT sku, unit_price_cents,
       NTILE(3) OVER (ORDER BY unit_price_cents) AS price_tercile
FROM products
ORDER BY unit_price_cents;
```

<!-- result -->
| sku | unit_price_cents | price_tercile |
|---|---|---|
| P02 | 250 | 1 |
| P09 | 350 | 1 |
| P06 | 450 | 1 |
| P01 | 1200 | 2 |
| P03 | 4900 | 2 |
| P07 | 5500 | 2 |
| P08 | 6500 | 3 |
| P05 | 8900 | 3 |
| P04 | 15900 | 3 |
<!-- /result -->

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| `WHERE ROW_NUMBER() OVER (…) <= 2` | `misuse of window function` | Compute in a CTE, filter outside |
| `ROW_NUMBER` without a tie-breaker | Results change between runs | Add a unique column to the window's `ORDER BY` |
| `RANK` when you need exactly N rows | Ties return more than N | `ROW_NUMBER` |
| Forgetting `PARTITION BY` | One ranking across everyone | Partition by the group |
| Integer share `100 * x / total` | 0 or truncated percentages | `100.0 * x / total` |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PI10` | **Salary rank within team.** Return team_name, full_name, salary_rank where salary_rank is RANK() by salary (highest = 1) within each team. Sort by team_name, salary_rank, full_name. | query |
| `PI11` | **Top two earners per team.** Return team_name, full_name, salary_cents for the two highest-paid employees of each team (use ROW_NUMBER; break salary ties by employee_id). Sort by team_name, then salary descending. | query |
| `PI33` | **Share of revenue.** For customers with paid revenue (lines of paid orders), return customer_id, revenue_cents and pct_of_total (their percentage of all paid revenue, rounded to 1 decimal). Sort by revenue_cents descending, then customer_id. | query |
| `PI34` | **Second-highest salary per team.** Return team_id, full_name, salary_cents for everyone who earns their team's second-highest distinct salary (keep ties). Sort by team_id, then full_name. | query |
| `PI35` | **Priciest product per category.** Return category_id, sku, unit_price_cents for the single most expensive product of each category (break price ties by sku). Sort by category_id. | query |

```bash
python tools/practice.py show PI10
python tools/practice.py check PI10
python tools/practice.py hint PI10 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** How does `AVG(x) OVER (PARTITION BY team_id)` differ from `GROUP BY team_id`?

   - **a)** It keeps every row and adds the team average to each
   - **b)** It is faster
   - **c)** It ignores NULLs

**2.** Salaries 100, 90, 90, 80. What does RANK give the 80?

   - **a)** 3
   - **b)** 4
   - **c)** 2

**3.** Why can't you write `WHERE ROW_NUMBER() OVER (…) <= 2`?

   - **a)** WHERE runs before window functions are computed
   - **b)** ROW_NUMBER needs GROUP BY
   - **c)** It is allowed

**4.** What does `SUM(revenue_cents) OVER ()` return on each row?

   - **a)** A running total
   - **b)** The grand total of all rows
   - **c)** The row's own value

```bash
python tools/quiz.py intermediate/05 1 b      # question 1, answer b
python tools/quiz.py intermediate/05           # list the questions
```
<!-- /quiz -->

## Summary

- `function OVER (PARTITION BY … ORDER BY …)` computes across related rows and keeps every row.
- `ROW_NUMBER`, `RANK`, `DENSE_RANK` differ only on ties. Choose from the question.
- Filter on window results in an outer query (CTE).
- Windows run after grouping, so you can rank aggregates and compute shares with `SUM(x) OVER ()`.

**Next:** [06 · LAG, LEAD, and running totals](06_windows_running.md)
