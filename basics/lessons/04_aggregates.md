# 04 · COUNT, SUM, MIN, MAX, AVG

> **You will learn** to summarise many rows into one with aggregate functions, the difference between `COUNT(*)`, `COUNT(column)` and `COUNT(DISTINCT column)`, how aggregates treat `NULL`, and what happens on an empty input.
> **Time:** about 40 minutes · **Before this:** [03 · Types and expressions](03_expressions.md)

"How many customers do we have? What did we earn? What's our cheapest product?" Each answer is **one value computed from many rows**. Aggregate functions compute it.

**Run the whole lesson:** `python tools/run_sql.py basics/lessons/04_aggregates.sql`

## 1. The five basic aggregates

| Function | Returns |
|---|---|
| `COUNT(*)` | the number of rows |
| `SUM(x)` | the total of `x` |
| `AVG(x)` | the average of `x`, as a real number |
| `MIN(x)`, `MAX(x)` | the smallest / largest `x` (numbers, text or dates) |

```sql
SELECT COUNT(*)              AS line_count,
       SUM(quantity)         AS units,
       MIN(unit_price_cents) AS cheapest_line_price,
       MAX(unit_price_cents) AS dearest_line_price,
       AVG(quantity)         AS avg_quantity
FROM order_items;
```

<!-- result -->
| line_count | units | cheapest_line_price | dearest_line_price | avg_quantity |
|---|---|---|---|---|
| 19 | 39 | 250 | 15900 | 2.0526315789473686 |
<!-- /result -->

Without `GROUP BY` (next lesson), an aggregate query returns **exactly one row**, however many rows went in.

`MIN` and `MAX` also work on ISO dates, because they sort as text:

```sql
SELECT MIN(ordered_at) AS first_order, MAX(ordered_at) AS last_order
FROM orders;
```

<!-- result -->
| first_order | last_order |
|---|---|
| 2026-01-12 | 2026-07-08 |
<!-- /result -->

## 2. Aggregates after WHERE

`WHERE` runs **first** and decides which rows reach the aggregate. "Paid revenue" is therefore a filter plus a sum:

```sql
SELECT COUNT(*) AS paid_orders
FROM orders
WHERE status = 'paid';
```

<!-- result -->
| paid_orders |
|---|
| 8 |
<!-- /result -->

```sql
SELECT SUM(amount_cents) AS card_cents
FROM payments
WHERE method = 'card';
```

<!-- result -->
| card_cents |
|---|
| 65600 |
<!-- /result -->

## 3. Three kinds of COUNT

- `COUNT(*)` counts rows.
- `COUNT(column)` counts rows where `column` **is not NULL**.
- `COUNT(DISTINCT column)` counts different non-NULL values.

```sql
SELECT COUNT(*)                   AS employees,
       COUNT(manager_id)          AS with_manager,
       COUNT(DISTINCT manager_id) AS distinct_managers
FROM employees;
```

<!-- result -->
| employees | with_manager | distinct_managers |
|---|---|---|
| 8 | 5 | 3 |
<!-- /result -->

Eight employees, five of whom have a manager, managed by three different people. Choosing the wrong `COUNT` is one of the most common reporting bugs.

## 4. NULL and empty inputs

`SUM`, `AVG`, `MIN` and `MAX` **ignore NULLs**. Over no rows at all, `COUNT` returns `0` but the others return `NULL`, not 0:

```sql
SELECT COUNT(*)          AS rows_found,
       SUM(amount_cents) AS total,
       COALESCE(SUM(amount_cents), 0) AS total_or_zero
FROM payments
WHERE method = 'cash' AND amount_cents > 1000000;
```

<!-- result -->
| rows_found | total | total_or_zero |
|---|---|---|
| 0 | *NULL* | 0 |
<!-- /result -->

`COALESCE(a, b)` returns the first argument that isn't `NULL`. Use it whenever "no rows" should be reported as zero.

`AVG` of integers is a real number. Round it for display, but keep full precision for further calculations:

```sql
SELECT AVG(unit_price_cents)           AS avg_price_cents,
       ROUND(AVG(unit_price_cents))    AS avg_price_rounded,
       ROUND(AVG(unit_price_cents), 1) AS avg_price_one_decimal
FROM products;
```

<!-- result -->
| avg_price_cents | avg_price_rounded | avg_price_one_decimal |
|---|---|---|
| 4883.333333333333 | 4883.0 | 4883.3 |
<!-- /result -->

## 5. What you can't mix

An aggregate query returns one row, so a plain column next to an aggregate is ambiguous: *which* row's value should it show? Most databases reject `SELECT full_name, MAX(salary_cents) FROM employees`. SQLite accepts it and picks the row with the maximum, but only in that special case. You'll learn the reliable way to answer "who earns the most?" in lessons 05, 06 and in the Intermediate level.

## Common mistakes

| Mistake | What happens | Fix |
|---|---|---|
| `COUNT(manager_id)` to count employees | Misses rows where it is NULL | `COUNT(*)` counts rows |
| Expecting `SUM` over no rows to be 0 | You get `NULL` | `COALESCE(SUM(x), 0)` |
| `AVG` on money, then storing the result | Fractions of a cent | Round on purpose, document how |
| Plain column next to an aggregate | Error elsewhere, surprising row in SQLite | Group by it (lesson 05) or join back |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PB10` | **Catalog size.** Return one row with two columns: customer_count (all customers) and product_count (all products). | query |
| `PB11` | **Units sold.** Return one row, total_quantity: the sum of quantity across all order lines (every status). | query |
| `PB12` | **Active price range.** Return one row with min_price and max_price, the lowest and highest unit_price_cents among active products. | query |
| `PB36` | **Who has a manager.** Return one row with all_employees (number of employees) and with_manager (number of employees whose manager_id is set). | query |
| `PB37` | **Average salary.** Return one row, avg_salary_cents: the average employee salary rounded to the nearest cent. | query |
| `PB38` | **Distinct buyers.** Return one row, buyers: the number of different customers who have placed at least one order of any status. | query |

```bash
python tools/practice.py show PB10
python tools/practice.py check PB10
python tools/practice.py hint PB10 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** `COUNT(manager_id)` on employees counts…

   - **a)** all employees
   - **b)** employees whose manager_id is not NULL
   - **c)** distinct managers

**2.** What does `SUM(amount_cents)` return when WHERE matches no rows?

   - **a)** 0
   - **b)** NULL
   - **c)** An error

**3.** Which runs first?

   - **a)** WHERE, then the aggregate
   - **b)** The aggregate, then WHERE
   - **c)** They run together

**4.** How many rows does `SELECT COUNT(*), SUM(quantity) FROM order_items;` return?

   - **a)** One per order line
   - **b)** One per order
   - **c)** Exactly one

```bash
python tools/quiz.py basics/04 1 b      # question 1, answer b
python tools/quiz.py basics/04           # list the questions
```
<!-- /quiz -->

## Summary

- Aggregates turn many rows into one: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`.
- `WHERE` filters rows before they are aggregated.
- `COUNT(*)` counts rows, `COUNT(col)` non-NULL values, `COUNT(DISTINCT col)` different values.
- Aggregates ignore NULL; over zero rows `SUM`/`AVG`/`MIN`/`MAX` give NULL, so use `COALESCE`.

**Next:** [05 · GROUP BY and HAVING](05_group_by_having.md)
