# 03 · Types and expressions

> **You will learn** to compute new values in a query: arithmetic, integer vs. real division, money in integer cents, text functions such as `UPPER`, `SUBSTR` and `||`, and type conversion with `CAST` and `typeof`.
> **Time:** about 45 minutes · **Before this:** [02 · ORDER BY and LIMIT](02_sort_limit.md)

The `SELECT` list doesn't have to be plain columns. Any **expression** works: arithmetic, function calls, text concatenation. The result is computed for each row; the stored data never changes.

**Run the whole lesson:** `python tools/run_sql.py basics/lessons/03_expressions.sql`

## 1. Arithmetic and line totals

`+`, `-`, `*`, `/` and `%` (remainder) work as you'd expect. A typical use is a line total: quantity times unit price.

```sql
SELECT order_id, product_id, quantity, unit_price_cents,
       quantity * unit_price_cents AS line_cents
FROM order_items
WHERE order_id IN (101, 105);
```

<!-- result -->
| order_id | product_id | quantity | unit_price_cents | line_cents |
|---|---|---|---|---|
| 101 | 1 | 2 | 1200 | 2400 |
| 101 | 2 | 3 | 250 | 750 |
| 105 | 5 | 2 | 8900 | 17800 |
| 105 | 6 | 4 | 450 | 1800 |
<!-- /result -->

Always alias a computed column. Otherwise its name is the expression text, which is awkward to read in code.

## 2. Integer division and money

When **both** operands are integers, `/` throws away the fraction. Write one operand as a real number (`100.0`) when you want decimals:

```sql
SELECT 7 / 2      AS integer_division,
       7 / 2.0    AS real_division,
       7 % 2      AS remainder,
       0.1 + 0.2  AS float_sum;
```

<!-- result -->
| integer_division | real_division | remainder | float_sum |
|---|---|---|---|
| 3 | 3.5 | 1 | 0.30000000000000004 |
<!-- /result -->

`0.1 + 0.2` is not exactly `0.3`: floating-point numbers can't represent most decimal fractions. That's why this course stores **money as integer cents** (`unit_price_cents = 1200` means €12.00). Integer cents add up exactly. Convert to euros only at the very end, for display:

```sql
SELECT sku,
       unit_price_cents,
       unit_price_cents * 90 / 100 AS ten_pct_off_cents,
       printf('%.2f', unit_price_cents / 100.0) AS price_eur
FROM products
ORDER BY sku
LIMIT 4;
```

<!-- result -->
| sku | unit_price_cents | ten_pct_off_cents | price_eur |
|---|---|---|---|
| P01 | 1200 | 1080 | 12.00 |
| P02 | 250 | 225 | 2.50 |
| P03 | 4900 | 4410 | 49.00 |
| P04 | 15900 | 14310 | 159.00 |
<!-- /result -->

- `unit_price_cents * 90 / 100` stays in integers and rounds **down** (250 → 225). Decide on purpose whether a discount rounds down, up or to the nearest cent. Here that's a business rule, not a technical detail.
- Multiply before you divide: `unit_price_cents / 100 * 90` loses the cents first.
- `printf('%.2f', …)` returns **text**. Use it only in the final output, never in further calculations.

## 3. Text functions

| Function | Example | Result |
|---|---|---|
| `a \|\| b` | `'P01' \|\| ': ' \|\| 'Notebook'` | `P01: Notebook` |
| `UPPER(t)`, `LOWER(t)` | `UPPER('Ana')` | `ANA` |
| `LENGTH(t)` | `LENGTH('Ana')` | `3` |
| `SUBSTR(t, start, n)` | `SUBSTR('2026-03-12', 1, 7)` | `2026-03` (positions start at 1) |
| `TRIM(t)`, `REPLACE(t, a, b)` | `REPLACE('a-b', '-', '/')` | `a/b` |
| `INSTR(t, part)` | `INSTR('ana@example.test', '@')` | `4` |

```sql
SELECT UPPER(full_name) AS name_upper,
       SUBSTR(email, INSTR(email, '@') + 1) AS email_domain,
       SUBSTR(joined_at, 1, 7) AS joined_month,
       LENGTH(full_name) AS name_length
FROM customers
ORDER BY customer_id
LIMIT 4;
```

<!-- result -->
| name_upper | email_domain | joined_month | name_length |
|---|---|---|---|
| ANA IONESCU | example.test | 2026-01 | 11 |
| BOGDAN POP | example.test | 2026-01 | 10 |
| CARMEN RADU | example.test | 2026-02 | 11 |
| DARIUS ENE | example.test | 2026-02 | 10 |
<!-- /result -->

`||` with a `NULL` gives `NULL`: `'Ada' || NULL` is `NULL`. Wrap nullable parts in `COALESCE(part, '')`.

`LENGTH` counts *characters*, so `'Iași'` has length 4 even though it needs five bytes in UTF-8. `UPPER` only changes ASCII letters in SQLite, which is why `Iași` would come out as `IAșI`. Full Unicode case rules need an extension or application code.

## 4. Types, typeof and CAST

SQLite is flexibly typed: the declared column type is a preference, and each *value* carries its own type. `typeof()` shows it, and `CAST` converts:

```sql
SELECT typeof(42)            AS int_type,
       typeof(4.2)           AS real_type,
       typeof('42')          AS text_type,
       typeof(NULL)          AS null_type,
       CAST('42' AS INTEGER) + 1 AS cast_sum,
       '10' < '9'            AS text_compare,
       10 < 9                AS number_compare;
```

<!-- result -->
| int_type | real_type | text_type | null_type | cast_sum | text_compare | number_compare |
|---|---|---|---|---|---|---|
| integer | real | text | null | 43 | 1 | 0 |
<!-- /result -->

`'10' < '9'` is true (1) because text compares character by character. When a number is stored as text, comparisons and sorting go wrong silently. That's why the schema declares `INTEGER` and uses `CHECK` constraints. PostgreSQL and most other databases are strictly typed and would reject many of these mixes.

`ROUND(x, n)` rounds a real number to *n* decimals: `ROUND(2.345, 2)`. It returns a real number, and should only be used for display or after integer money arithmetic is finished.

## Common mistakes

| Mistake | What happens | Fix |
|---|---|---|
| `SELECT 1 / 3` expecting 0.33 | `0`: integer division | `1 / 3.0` or `CAST(1 AS REAL) / 3` |
| Storing money as `REAL` | Totals drift by fractions of a cent | Integer cents |
| `price / 100 * 90` | Cents are lost before the multiply | Multiply first: `price * 90 / 100` |
| Concatenating a nullable column | The whole result becomes `NULL` | `COALESCE(col, '')` |
| Numbers stored as text | `'10' < '9'`, wrong sort order | Store numbers in numeric columns |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PB09` | **Product labels.** Return one column named product_label in the form 'P01: Notebook' (sku, colon, space, product name) for every product, sorted by sku. The column name is checked. | query |
| `PB31` | **Line totals.** Return order_id, product_id, line_cents (quantity × unit_price_cents) for every order line, sorted by order_id then product_id. | query |
| `PB32` | **Ten percent off.** Return sku, discounted_cents for every product, where discounted_cents is the price with 10% off, rounded down to whole cents using integer arithmetic. Sort by sku. | query |
| `PB33` | **Prices in euros.** Return sku and price_eur, the price as text with two decimals (1200 cents → '12.00'), for active products, sorted by sku. | query |
| `PB34` | **Upper-case names.** Return customer_id and name_upper (the full name in upper case) for every customer, sorted by customer_id. | query |
| `PB35` | **Longest names first.** Return full_name, name_length (number of characters) for every customer, longest first, ties by full_name. | query |

```bash
python tools/practice.py show PB09
python tools/practice.py check PB09
python tools/practice.py hint PB09 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** What is `7 / 2` in SQLite?

   - **a)** 3.5
   - **b)** 3
   - **c)** 4

**2.** Why does the course store prices as integer cents?

   - **a)** Integers are exact; floats like 0.1 + 0.2 are not
   - **b)** SQLite has no REAL type
   - **c)** It uses less disk

**3.** What is `'Ada' || NULL`?

   - **a)** 'Ada'
   - **b)** 'AdaNULL'
   - **c)** NULL

**4.** Why is `'10' < '9'` true?

   - **a)** Text compares character by character
   - **b)** SQLite bug
   - **c)** Because 10 has two digits

```bash
python tools/quiz.py basics/03 1 b      # question 1, answer b
python tools/quiz.py basics/03           # list the questions
```
<!-- /quiz -->

## Summary

- Any expression can appear in `SELECT`; alias it.
- Integer `/` integer truncates. Use `100.0` for real division.
- Keep money in integer cents; format with `printf('%.2f', cents / 100.0)` only at the end.
- `||`, `UPPER`, `LOWER`, `LENGTH`, `SUBSTR`, `INSTR`, `REPLACE` handle text. `NULL` spreads through `||`.
- `typeof` shows a value's type, `CAST` converts it; text and numbers compare differently.

**Next:** [04 · COUNT, SUM, MIN, MAX, AVG](04_aggregates.md)
