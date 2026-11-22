# 02 · ORDER BY and LIMIT

> **You will learn** to sort results with `ORDER BY` (ascending, descending, on several keys), why a tie-breaker makes results reliable, how `LIMIT` and `OFFSET` page through rows, and where `NULL` lands in a sort.
> **Time:** about 35 minutes · **Before this:** [01 · WHERE, comparisons, and NULL](01_where_null.md)

A table has no order. Without `ORDER BY`, the database may return rows in any order it finds convenient, and that order can change when data grows, an index is added or you switch database. **If the order matters, ask for it.**

**Run the whole lesson:** `python tools/run_sql.py basics/lessons/02_sort_limit.sql`

## 1. Sorting with ORDER BY

`ORDER BY` comes after `WHERE`. `ASC` (ascending, the default) sorts small to large and A to Z; `DESC` reverses it.

```sql
SELECT sku, product_name, unit_price_cents
FROM products
WHERE active = 1
ORDER BY unit_price_cents DESC;
```

<!-- result -->
| sku | product_name | unit_price_cents |
|---|---|---|
| P04 | Keyboard | 15900 |
| P05 | Desk Lamp | 8900 |
| P08 | Mouse | 6500 |
| P07 | SQL Handbook | 5500 |
| P03 | Python Handbook | 4900 |
| P01 | Notebook | 1200 |
| P06 | Marker | 450 |
| P02 | Pen | 250 |
<!-- /result -->

- You can sort by a column you don't select, or by an alias defined in the `SELECT` list.
- Text sorts by character codes: uppercase before lowercase, and accented letters after `z`. Real systems choose a *collation* to control this.

## 2. Several sort keys and ties

When two rows have the same value for the first key, the second key decides, and so on:

```sql
SELECT customer_id, order_id, ordered_at
FROM orders
ORDER BY customer_id, ordered_at DESC;
```

<!-- result -->
| customer_id | order_id | ordered_at |
|---|---|---|
| 1 | 103 | 2026-03-02 |
| 1 | 101 | 2026-01-12 |
| 2 | 108 | 2026-05-14 |
| 2 | 102 | 2026-02-05 |
| 3 | 111 | 2026-07-08 |
| 3 | 104 | 2026-03-12 |
| 4 | 105 | 2026-04-06 |
| 5 | 106 | 2026-04-15 |
| 6 | 107 | 2026-05-04 |
| 7 | 109 | 2026-06-02 |
| 8 | 110 | 2026-06-21 |
<!-- /result -->

Each key has its own direction: here `customer_id` ascends while `ordered_at` descends.

If the keys don't identify a single row, the order *within* a tie is undefined. Two products cost 250 cents in the edge-case fixture the exercises use, so "the cheapest product" has no single answer unless you add a tie-breaker:

```sql
SELECT sku, unit_price_cents
FROM products
ORDER BY unit_price_cents, sku;
```

<!-- result -->
| sku | unit_price_cents |
|---|---|
| P02 | 250 |
| P09 | 350 |
| P06 | 450 |
| P01 | 1200 |
| P03 | 4900 |
| P07 | 5500 |
| P08 | 6500 |
| P05 | 8900 |
| P04 | 15900 |
<!-- /result -->

**Rule of thumb:** end every `ORDER BY` with a column that is unique, such as the primary key or `sku`, whenever the result is paginated, limited or compared by a test.

## 3. LIMIT and OFFSET

`LIMIT n` keeps the first *n* rows **after** sorting. `OFFSET m` skips *m* rows first, which is the classic way to show "page 2":

```sql
SELECT order_id, ordered_at
FROM orders
ORDER BY ordered_at DESC, order_id DESC
LIMIT 3;
```

<!-- result -->
| order_id | ordered_at |
|---|---|
| 111 | 2026-07-08 |
| 110 | 2026-06-21 |
| 109 | 2026-06-02 |
<!-- /result -->

```sql
SELECT order_id, ordered_at
FROM orders
ORDER BY ordered_at DESC, order_id DESC
LIMIT 3 OFFSET 3;
```

<!-- result -->
| order_id | ordered_at |
|---|---|
| 108 | 2026-05-14 |
| 107 | 2026-05-04 |
| 106 | 2026-04-15 |
<!-- /result -->

- `LIMIT` without `ORDER BY` returns *some* rows, not the first or the latest ones.
- `OFFSET` gets slow on large tables (the database still reads every skipped row) and can show a row twice or skip one if data changes between page requests. The Advanced level teaches *keyset pagination* for that.

## 4. Where does NULL go?

In SQLite, `NULL` sorts **before** every other value in ascending order and after them in descending order. PostgreSQL does the opposite by default, so state the rule you want:

```sql
SELECT full_name, manager_id
FROM employees
ORDER BY manager_id IS NULL, manager_id, employee_id;
```

<!-- result -->
| full_name | manager_id |
|---|---|
| Ben | 1 |
| Fadi | 1 |
| Dina | 3 |
| Hugo | 3 |
| Gina | 5 |
| Ada | *NULL* |
| Cleo | *NULL* |
| Ema | *NULL* |
<!-- /result -->

`manager_id IS NULL` is `0` (false) or `1` (true), so sorting by it first puts the people without a manager last. SQLite 3.30+ and PostgreSQL also accept `ORDER BY manager_id NULLS LAST`.

## Common mistakes

| Mistake | What happens | Fix |
|---|---|---|
| No `ORDER BY` | The order can change between runs, servers or versions | Always sort when order matters |
| `ORDER BY price DESC, sku DESC` when you meant ties A→Z | `DESC` applies to one key only | Give each key its own direction |
| `LIMIT` before deciding the sort | "Top 3" is not the top 3 | `ORDER BY … LIMIT` together |
| No tie-breaker on a paginated list | Rows jump between pages | Add a unique key last |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PB07` | **Latest three orders.** Return order_id, ordered_at for the three most recent orders. Newest first; break date ties by the higher order_id first. | query |
| `PB08` | **Premium shelf.** Return sku, product_name, unit_price_cents for the three most expensive active products, price high to low, ties by sku. | query |
| `PB27` | **Two cheapest active products.** Return sku, unit_price_cents for the two cheapest active products, cheapest first, ties broken by sku. | query |
| `PB28` | **Second page of products.** Products are listed by sku, three per page. Return sku, product_name for page 2. | query |
| `PB29` | **Customers Z to A.** Return full_name, city for every customer, sorted by full_name from Z to A. | query |
| `PB30` | **Managers last.** Return full_name, manager_id for every employee: employees with a manager first (by manager_id, then employee_id), and employees without a manager last (by employee_id). | query |

```bash
python tools/practice.py show PB07
python tools/practice.py check PB07
python tools/practice.py hint PB07 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** What order does a query without ORDER BY return rows in?

   - **a)** Insertion order
   - **b)** Primary key order
   - **c)** Undefined: whatever the database finds convenient

**2.** In `ORDER BY price DESC, sku`, how is sku sorted?

   - **a)** Ascending
   - **b)** Descending
   - **c)** Not at all

**3.** `LIMIT 3 OFFSET 3` returns…

   - **a)** rows 1–3
   - **b)** rows 4–6 of the sorted result
   - **c)** rows 3–6

**4.** Where does SQLite put NULL in `ORDER BY manager_id` (ascending)?

   - **a)** First
   - **b)** Last
   - **c)** It drops NULL rows

```bash
python tools/quiz.py basics/02 1 b      # question 1, answer b
python tools/quiz.py basics/02           # list the questions
```
<!-- /quiz -->

## Summary

- Without `ORDER BY`, row order is undefined.
- Sort keys are applied left to right, each with its own `ASC`/`DESC`.
- End the sort with a unique column to make results deterministic.
- `LIMIT`/`OFFSET` apply after sorting; `OFFSET` gets expensive and unstable on big, changing tables.
- SQLite puts `NULL` first in ascending order. Control it with `col IS NULL` or `NULLS LAST`.

**Next:** [03 · Types and expressions](03_expressions.md)
