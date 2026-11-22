# 01 · Scalar, IN, and derived-table subqueries

> **You will learn** the three shapes of subquery (a single value, a list of values, a whole table), where each can be used, how a **correlated** subquery refers to the outer row, and the `NULL` pitfalls of `IN` and `NOT IN`.
> **Time:** about 50 minutes · **Before this:** [00 · Multi-table reporting](00_multi_table_reports.md)

A **subquery** is a `SELECT` inside another statement, in parentheses. It lets one query use the answer of another: "products above the *average* price", "customers who *have paid orders*". What a subquery may return decides where you can put it.

**Run the whole lesson:** `python tools/run_sql.py intermediate/lessons/01_subqueries.sql`

## 1. Scalar subqueries: exactly one value

A **scalar** subquery returns one row and one column. It can go anywhere a single value can: in `WHERE`, in the `SELECT` list, in arithmetic.

```sql
SELECT sku, product_name, unit_price_cents,
       (SELECT AVG(unit_price_cents) FROM products) AS avg_price
FROM products
WHERE unit_price_cents > (SELECT AVG(unit_price_cents) FROM products)
ORDER BY unit_price_cents DESC;
```

<!-- result -->
| sku | product_name | unit_price_cents | avg_price |
|---|---|---|---|
| P04 | Keyboard | 15900 | 4883.333333333333 |
| P05 | Desk Lamp | 8900 | 4883.333333333333 |
| P08 | Mouse | 6500 | 4883.333333333333 |
| P07 | SQL Handbook | 5500 | 4883.333333333333 |
| P03 | Python Handbook | 4900 | 4883.333333333333 |
<!-- /result -->

- If a scalar subquery returns **no rows**, its value is `NULL`.
- If it returns **several rows**, SQLite silently uses the first one, while PostgreSQL raises an error. Write scalar subqueries so they can only return one row: an aggregate, or a filter on a unique key.

## 2. IN subqueries: a list of values

`x IN (SELECT col …)` is true when `x` equals any value the subquery returns.

```sql
SELECT customer_id, full_name
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders WHERE status = 'pending')
ORDER BY customer_id;
```

<!-- result -->
| customer_id | full_name |
|---|---|
| 2 | Bogdan Pop |
| 3 | Carmen Radu |
<!-- /result -->

`IN` never duplicates outer rows, even if a customer has several pending orders. That's an advantage over a join, which would repeat the customer once per order.

### The NOT IN trap

`NOT IN` has a nasty edge: if the subquery returns even one `NULL`, `x NOT IN (…)` is never true, because "is x different from NULL?" is unknown. "Employees who manage nobody" looks easy:

```sql
SELECT full_name
FROM employees
WHERE employee_id NOT IN (SELECT manager_id FROM employees);
```

<!-- result -->
| full_name |
|---|
| *(no rows)* |
<!-- /result -->

No rows, because top-level employees have `manager_id = NULL`. Filter the NULLs out, or use `NOT EXISTS` (next lesson), which has no such trap:

```sql
SELECT full_name
FROM employees
WHERE employee_id NOT IN (SELECT manager_id FROM employees WHERE manager_id IS NOT NULL)
ORDER BY employee_id;
```

<!-- result -->
| full_name |
|---|
| Ben |
| Dina |
| Fadi |
| Gina |
| Hugo |
<!-- /result -->

## 3. Derived tables: a subquery in FROM

A subquery in `FROM` acts as a temporary table. It **must** have an alias. Use it to aggregate in one step and filter or join in the next:

```sql
SELECT t.team_name, s.headcount, s.avg_salary_cents
FROM (SELECT team_id, COUNT(*) AS headcount, ROUND(AVG(salary_cents)) AS avg_salary_cents
      FROM employees
      GROUP BY team_id) AS s
JOIN teams t ON t.team_id = s.team_id
ORDER BY s.avg_salary_cents DESC;
```

<!-- result -->
| team_name | headcount | avg_salary_cents |
|---|---|---|
| Engineering | 3 | 9333333.0 |
| Sales | 3 | 7766667.0 |
| Support | 2 | 5750000.0 |
<!-- /result -->

## 4. Correlated subqueries

A subquery that refers to a column of the **outer** query is *correlated*. It is logically evaluated once per outer row. "Employees paid above *their own team's* average":

```sql
SELECT e.full_name, e.team_id, e.salary_cents
FROM employees e
WHERE e.salary_cents > (SELECT AVG(x.salary_cents)
                        FROM employees x
                        WHERE x.team_id = e.team_id)
ORDER BY e.team_id, e.salary_cents DESC;
```

<!-- result -->
| full_name | team_id | salary_cents |
|---|---|---|
| Ada | 1 | 12000000 |
| Cleo | 2 | 9500000 |
| Ema | 3 | 6500000 |
<!-- /result -->

`e.team_id` inside the subquery is the current outer row's team. Give both copies of the table different aliases (`e`, `x`) so it's obvious which is which.

Correlated subqueries are clear for small "per row" questions. On large tables a join to a pre-aggregated derived table is often faster, and the Advanced level shows how to rewrite one into the other.

## 5. Choosing a shape

| You need | Use | Must return |
|---|---|---|
| one number to compare or display | scalar subquery | 1 row × 1 column |
| membership in a set | `IN (subquery)` / `EXISTS` | 1 column, any rows |
| an intermediate result to join or filter | derived table (or a CTE, lesson 03) | any table, with an alias |
| a per-row calculation | correlated subquery | depends on where it's used |

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| `NOT IN` over a nullable column | Zero rows | `WHERE col IS NOT NULL` inside, or `NOT EXISTS` |
| Scalar subquery returning many rows | Arbitrary value (SQLite) or error (PostgreSQL) | Aggregate, or filter on a unique key |
| Derived table without an alias | Syntax error in most databases | `(…) AS name` |
| Same alias inside and outside | The subquery silently refers to the wrong row | Different aliases |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PI03` | **Above-average prices.** Return sku, unit_price_cents for products priced above the average price of all products. Sort by price descending, then sku. | query |
| `PI23` | **Above their team's average.** Return full_name, team_id, salary_cents for employees paid more than the average salary of their own team, sorted by team_id, then salary descending. | query |
| `PI24` | **Products sold in paid orders.** Using IN with a subquery, return sku, product_name for products that appear in at least one paid order, sorted by sku. | query |
| `PI25` | **Bigger teams.** Using a derived table (a subquery in FROM), return team_name, headcount for teams with at least two employees, sorted by team_name. | query |

```bash
python tools/practice.py show PI03
python tools/practice.py check PI03
python tools/practice.py hint PI03 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** Why does `employee_id NOT IN (SELECT manager_id FROM employees)` return no rows?

   - **a)** manager_id contains NULL
   - **b)** NOT IN is not supported
   - **c)** Every employee is a manager

**2.** What does a scalar subquery return when it finds no rows?

   - **a)** 0
   - **b)** An error
   - **c)** NULL

**3.** A correlated subquery…

   - **a)** runs once for the whole query
   - **b)** refers to a column of the outer query's current row
   - **c)** must be in FROM

**4.** What must a derived table (subquery in FROM) have?

   - **a)** An ORDER BY
   - **b)** An alias
   - **c)** A GROUP BY

```bash
python tools/quiz.py intermediate/01 1 b      # question 1, answer b
python tools/quiz.py intermediate/01           # list the questions
```
<!-- /quiz -->

## Summary

- Scalar subqueries return one value; `IN` subqueries a column of values; derived tables a whole table.
- `NOT IN` returns nothing if the list contains `NULL`.
- A correlated subquery refers to the outer row and is evaluated per row.
- Give every derived table an alias, and different aliases to the inner and outer copies of a table.

**Next:** [02 · EXISTS and correlated subqueries](02_exists.md)
