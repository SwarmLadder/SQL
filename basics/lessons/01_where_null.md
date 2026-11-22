# 01 · WHERE, comparisons, and NULL

> **You will learn** to keep only the rows you need with `WHERE`, to combine conditions with `AND`, `OR` and `NOT`, to use `IN`, `BETWEEN` and `LIKE`, and to handle missing values with `IS NULL`.
> **Time:** about 45 minutes · **Before this:** [00 · SELECT and columns](00_select.md)

`SELECT` chooses columns; `WHERE` chooses rows. The database checks the condition once per row and keeps the row only when the condition is **true**. That last word matters more than it seems; section 4 explains why.

**Run the whole lesson:** `python tools/run_sql.py basics/lessons/01_where_null.sql`

## 1. Comparisons

The comparison operators are `=`, `<>` (or `!=`), `<`, `<=`, `>` and `>=`. Text values go in **single quotes**.

```sql
SELECT order_id, status
FROM orders
WHERE status = 'pending';
```

<!-- result -->
| order_id | status |
|---|---|
| 104 | pending |
| 108 | pending |
<!-- /result -->

```sql
SELECT sku, product_name, unit_price_cents
FROM products
WHERE unit_price_cents >= 6000;
```

<!-- result -->
| sku | product_name | unit_price_cents |
|---|---|---|
| P04 | Keyboard | 15900 |
| P05 | Desk Lamp | 8900 |
| P08 | Mouse | 6500 |
<!-- /result -->

- Text comparison with `=` is case-sensitive in SQLite: `'Paid'` does not match `'paid'`.
- Double quotes mean *identifier* (a column or table name), not text. Always quote text with `'…'`.
- Dates stored as `YYYY-MM-DD` text compare correctly: `ordered_at >= '2026-06-01'` works because the text sorts in date order.

## 2. AND, OR, NOT and parentheses

`AND` needs both sides to be true, `OR` needs at least one, and `NOT` flips a condition.

```sql
SELECT sku, unit_price_cents, active
FROM products
WHERE active = 1 AND unit_price_cents < 1000;
```

<!-- result -->
| sku | unit_price_cents | active |
|---|---|---|
| P02 | 250 | 1 |
| P06 | 450 | 1 |
<!-- /result -->

`AND` binds tighter than `OR`, just as `×` binds tighter than `+`. The next query looks like "paid orders of customer 1 or 2", but it actually means "paid orders of customer 1, **or** any order of customer 2":

```sql
SELECT order_id, customer_id, status
FROM orders
WHERE status = 'paid' AND customer_id = 1 OR customer_id = 2;
```

<!-- result -->
| order_id | customer_id | status |
|---|---|---|
| 101 | 1 | paid |
| 103 | 1 | paid |
| 102 | 2 | paid |
| 108 | 2 | pending |
<!-- /result -->

Order 108 is pending and still appears. Parentheses say what you mean:

```sql
SELECT order_id, customer_id, status
FROM orders
WHERE status = 'paid' AND (customer_id = 1 OR customer_id = 2);
```

<!-- result -->
| order_id | customer_id | status |
|---|---|---|
| 101 | 1 | paid |
| 103 | 1 | paid |
| 102 | 2 | paid |
<!-- /result -->

**Rule of thumb:** whenever a `WHERE` mixes `AND` and `OR`, add parentheses, even if you think you don't need them.

## 3. IN, BETWEEN and LIKE

These are shorthand for common conditions:

| Shorthand | Means |
|---|---|
| `status IN ('pending', 'cancelled')` | `status = 'pending' OR status = 'cancelled'` |
| `price BETWEEN 1000 AND 6000` | `price >= 1000 AND price <= 6000` (both ends included) |
| `product_name LIKE '%Handbook%'` | the text contains "Handbook" (`%` = any characters, `_` = exactly one) |

```sql
SELECT sku, product_name, unit_price_cents
FROM products
WHERE unit_price_cents BETWEEN 1000 AND 6000
  AND product_name LIKE '%Handbook%';
```

<!-- result -->
| sku | product_name | unit_price_cents |
|---|---|---|
| P03 | Python Handbook | 4900 |
| P07 | SQL Handbook | 5500 |
<!-- /result -->

- `NOT IN`, `NOT BETWEEN` and `NOT LIKE` negate them.
- In SQLite, `LIKE` ignores case for ASCII letters (`'%handbook%'` also matches). Other databases differ, so don't rely on it.
- `BETWEEN` with dates includes both ends: `BETWEEN '2026-03-01' AND '2026-03-31'` covers the whole of March for date-only values.

## 4. NULL: the missing value

`NULL` means *unknown* or *not applicable*. Here a top-level employee has no manager, so their `manager_id` is `NULL`. The surprise is that **any comparison with NULL is neither true nor false, but unknown**, and `WHERE` keeps only *true* rows:

```sql
SELECT employee_id, full_name
FROM employees
WHERE manager_id = NULL;
```

<!-- result -->
| employee_id | full_name |
|---|---|
| *(no rows)* |  |
<!-- /result -->

No rows, even though three employees have no manager. Use `IS NULL` and `IS NOT NULL`:

```sql
SELECT employee_id, full_name, manager_id
FROM employees
WHERE manager_id IS NULL;
```

<!-- result -->
| employee_id | full_name | manager_id |
|---|---|---|
| 1 | Ada | *NULL* |
| 3 | Cleo | *NULL* |
| 5 | Ema | *NULL* |
<!-- /result -->

The unknown result also hides rows from `<>`. "Employees whose manager is not Ada (employee 1)" silently drops the people who have no manager at all:

```sql
SELECT full_name, manager_id
FROM employees
WHERE manager_id <> 1
ORDER BY employee_id;
```

<!-- result -->
| full_name | manager_id |
|---|---|
| Dina | 3 |
| Gina | 5 |
| Hugo | 3 |
<!-- /result -->

If those rows belong in the answer, say so explicitly: `WHERE manager_id <> 1 OR manager_id IS NULL`.

This is SQL's **three-valued logic**: true, false and unknown. `NOT unknown` is still unknown, so wrapping a condition in `NOT` doesn't bring NULL rows back.

## Common mistakes

| Mistake | What happens | Fix |
|---|---|---|
| `WHERE manager_id = NULL` | Always zero rows | `WHERE manager_id IS NULL` |
| `WHERE status = "paid"` | Compares with a column named `paid`, or errors | Single quotes for text: `'paid'` |
| Mixing `AND` and `OR` without parentheses | Extra rows that match only part of the condition | Add parentheses |
| `WHERE price BETWEEN 6000 AND 1000` | No rows: the lower bound must come first | `BETWEEN low AND high` |
| `<>` on a nullable column | Rows with NULL silently disappear | Add `OR column IS NULL` if they belong in the result |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PB04` | **Cheap products.** Return sku, unit_price_cents for products cheaper than 500 cents (any active state), cheapest first, ties by sku. | query |
| `PB05` | **Orders needing attention.** Return order_id, status for orders that are pending or cancelled, sorted by order_id. | query |
| `PB06` | **Top of the org chart.** Return employee_id, full_name for employees without a manager, sorted by employee_id. | query |
| `PB24` | **Mid-priced active products.** Return sku, unit_price_cents for active products priced from 1000 to 6000 cents inclusive, sorted by unit_price_cents then sku. | query |
| `PB25` | **Paid orders of two customers.** Return order_id, customer_id for paid orders placed by customer 1 or customer 2, sorted by order_id. | query |
| `PB26` | **Managed staff under 8 000 000.** Return employee_id, full_name, salary_cents for employees who have a manager and earn less than 8000000 cents, sorted by employee_id. | query |

```bash
python tools/practice.py show PB04
python tools/practice.py check PB04
python tools/practice.py hint PB04 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** Which condition finds employees without a manager?

   - **a)** manager_id = NULL
   - **b)** manager_id IS NULL
   - **c)** manager_id = ''

**2.** `WHERE status = 'paid' AND customer_id = 1 OR customer_id = 2` also returns…

   - **a)** a pending order of customer 2
   - **b)** nothing extra
   - **c)** a syntax error

**3.** `price BETWEEN 1000 AND 6000` includes a price of exactly 6000?

   - **a)** No
   - **b)** Only for integers
   - **c)** Yes

**4.** `WHERE manager_id <> 1` on employees returns rows whose manager_id is NULL?

   - **a)** Yes, NULL is not 1
   - **b)** No, the comparison is unknown
   - **c)** Only in PostgreSQL

```bash
python tools/quiz.py basics/01 1 b      # question 1, answer b
python tools/quiz.py basics/01           # list the questions
```
<!-- /quiz -->

## Summary

- `WHERE` keeps a row only when its condition is **true**.
- `AND` binds tighter than `OR`. Use parentheses whenever you mix them.
- `IN`, `BETWEEN` (inclusive) and `LIKE` (`%`, `_`) are shorthands for common conditions.
- Comparing anything with `NULL` gives *unknown*. Test with `IS NULL` / `IS NOT NULL`.

**Next:** [02 · ORDER BY and LIMIT](02_sort_limit.md)
