# 04 · CASE and conditional aggregation

> **You will learn** to compute values that depend on conditions with `CASE`, why branch order and `ELSE` matter, and to build pivot-style reports with `SUM(CASE …)` and `COUNT(CASE …)`.
> **Time:** about 45 minutes · **Before this:** [03 · Common table expressions](03_cte.md)

`CASE` is SQL's if/else. It's an expression, so it works anywhere a value does: in `SELECT`, `WHERE`, `ORDER BY`, and, most powerfully, inside aggregates.

**Run the whole lesson:** `python tools/run_sql.py intermediate/lessons/04_case_conditional.sql`

## 1. Searched CASE

```sql
SELECT sku, unit_price_cents,
       CASE
         WHEN unit_price_cents < 1000  THEN 'budget'
         WHEN unit_price_cents < 10000 THEN 'standard'
         ELSE 'premium'
       END AS price_band
FROM products
ORDER BY unit_price_cents;
```

<!-- result -->
| sku | unit_price_cents | price_band |
|---|---|---|
| P02 | 250 | budget |
| P09 | 350 | budget |
| P06 | 450 | budget |
| P01 | 1200 | standard |
| P03 | 4900 | standard |
| P07 | 5500 | standard |
| P08 | 6500 | standard |
| P05 | 8900 | standard |
| P04 | 15900 | premium |
<!-- /result -->

- Branches are tested **top to bottom**; the first true one wins. Because `< 1000` is tested first, the second branch only sees prices of 1000 and above, so `< 10000` is enough.
- Without `ELSE`, an unmatched row gets `NULL`. Always decide what should happen: a real default, or a loud `'unknown'`.

## 2. Simple CASE and CASE for sorting

When every branch compares the same expression for equality, the *simple* form is shorter:

```sql
SELECT order_id, status,
       CASE status WHEN 'paid' THEN 'done'
                   WHEN 'pending' THEN 'waiting'
                   ELSE 'closed' END AS stage
FROM orders
ORDER BY CASE status WHEN 'pending' THEN 0 WHEN 'paid' THEN 1 ELSE 2 END,
         order_id;
```

<!-- result -->
| order_id | status | stage |
|---|---|---|
| 104 | pending | waiting |
| 108 | pending | waiting |
| 101 | paid | done |
| 102 | paid | done |
| 103 | paid | done |
| 105 | paid | done |
| 107 | paid | done |
| 109 | paid | done |
| 110 | paid | done |
| 111 | paid | done |
| 106 | cancelled | closed |
<!-- /result -->

The `ORDER BY CASE …` sorts by a business priority (pending first) instead of alphabetically.

## 3. Conditional aggregation: many counts in one pass

Put a `CASE` inside an aggregate to count or sum only some rows. Every group then gets several filtered numbers in a single scan. This is how you **pivot** rows into columns.

```sql
SELECT SUBSTR(ordered_at, 1, 7) AS month,
       COUNT(*) AS orders,
       SUM(CASE WHEN status = 'paid'      THEN 1 ELSE 0 END) AS paid,
       SUM(CASE WHEN status = 'pending'   THEN 1 ELSE 0 END) AS pending,
       SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled
FROM orders
GROUP BY month
ORDER BY month;
```

<!-- result -->
| month | orders | paid | pending | cancelled |
|---|---|---|---|---|
| 2026-01 | 1 | 1 | 0 | 0 |
| 2026-02 | 1 | 1 | 0 | 0 |
| 2026-03 | 2 | 1 | 1 | 0 |
| 2026-04 | 2 | 1 | 0 | 1 |
| 2026-05 | 2 | 1 | 1 | 0 |
| 2026-06 | 2 | 2 | 0 | 0 |
| 2026-07 | 1 | 1 | 0 | 0 |
<!-- /result -->

Two equivalent spellings:

- `COUNT(CASE WHEN status = 'paid' THEN 1 END)`: no `ELSE`, so non-matches are `NULL`, which `COUNT` skips.
- `SUM(status = 'paid')`: in SQLite a comparison is 0 or 1. It's short, but not portable to PostgreSQL (use `COUNT(*) FILTER (WHERE …)` there).

## 4. Conditional sums of money

The same idea works for amounts. Revenue split by payment method, per month:

```sql
SELECT SUBSTR(paid_at, 1, 7) AS month,
       SUM(CASE WHEN method = 'card'     THEN amount_cents ELSE 0 END) AS card_cents,
       SUM(CASE WHEN method = 'transfer' THEN amount_cents ELSE 0 END) AS transfer_cents,
       SUM(CASE WHEN method = 'cash'     THEN amount_cents ELSE 0 END) AS cash_cents,
       SUM(amount_cents) AS total_cents
FROM payments
GROUP BY month
ORDER BY month;
```

<!-- result -->
| month | card_cents | transfer_cents | cash_cents | total_cents |
|---|---|---|---|---|
| 2026-01 | 3150 | 0 | 0 | 3150 |
| 2026-02 | 0 | 5400 | 0 | 5400 |
| 2026-03 | 22400 | 0 | 0 | 22400 |
| 2026-04 | 0 | 0 | 19600 | 19600 |
| 2026-05 | 10100 | 0 | 0 | 10100 |
| 2026-06 | 16150 | 11350 | 0 | 27500 |
| 2026-07 | 13800 | 0 | 0 | 13800 |
<!-- /result -->

**Check it:** the method columns of each row must add up to `total_cents`. If a new method appeared, the sum would fall short, and that's exactly why a total column is worth keeping.

## 5. CASE with NULL

`CASE WHEN x = NULL` never matches, just like `WHERE`. Test `IS NULL`, and remember a simple `CASE x WHEN NULL` doesn't work either:

```sql
SELECT full_name,
       CASE WHEN manager_id IS NULL THEN 'lead' ELSE 'member' END AS role
FROM employees
ORDER BY role, full_name;
```

<!-- result -->
| full_name | role |
|---|---|
| Ada | lead |
| Cleo | lead |
| Ema | lead |
| Ben | member |
| Dina | member |
| Fadi | member |
| Gina | member |
| Hugo | member |
<!-- /result -->

`COALESCE(x, default)` is shorthand for `CASE WHEN x IS NOT NULL THEN x ELSE default END`.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Branches in the wrong order | Everything lands in the first, broadest branch | Most specific / lowest threshold first |
| Missing `ELSE` | Unexpected `NULL`s | Add an explicit `ELSE` |
| `COUNT(CASE … ELSE 0 END)` | Counts every row (0 is not NULL) | `SUM(… ELSE 0)` or `COUNT(… END)` without ELSE |
| `CASE x WHEN NULL` | Never matches | `CASE WHEN x IS NULL` |
| Hard-coded categories with no total | New values silently missing | Keep a total column and compare |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PI08` | **Status counts in one row.** Return one row with paid_count, pending_count, cancelled_count using conditional aggregation over orders. | query |
| `PI09` | **Price bands.** Return sku, price_band for every product, where price_band is 'budget' below 1000 cents, 'standard' from 1000 to 9999, and 'premium' from 10000 up. Sort by sku. | query |
| `PI30` | **Payment method pivot.** Return month (paid_at as YYYY-MM), card_cents, transfer_cents, cash_cents (0 when a method has no payments that month), sorted by month. | query |
| `PI31` | **High earners per team.** Return team_id, staff (number of employees) and high_earners (employees earning more than 8000000 cents) for each team that has employees, sorted by team_id. | query |
| `PI32` | **Work queue order.** Return order_id, status for every order, sorted pending first, then paid, then cancelled, and by order_id within each status. | query |

```bash
python tools/practice.py show PI08
python tools/practice.py check PI08
python tools/practice.py hint PI08 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** Which branch of a CASE wins when several are true?

   - **a)** The last one
   - **b)** The first one
   - **c)** An error is raised

**2.** What does a CASE without ELSE return when nothing matches?

   - **a)** 0
   - **b)** ''
   - **c)** NULL

**3.** `COUNT(CASE WHEN status = 'paid' THEN 1 ELSE 0 END)` counts…

   - **a)** paid orders
   - **b)** all orders
   - **c)** unpaid orders

**4.** Why keep a total column next to pivoted method columns?

   - **a)** To detect values none of the branches cover
   - **b)** SQL requires it
   - **c)** For sorting

```bash
python tools/quiz.py intermediate/04 1 b      # question 1, answer b
python tools/quiz.py intermediate/04           # list the questions
```
<!-- /quiz -->

## Summary

- `CASE WHEN … THEN … ELSE … END` returns the first matching branch's value.
- Order branches carefully and always decide on `ELSE`.
- `SUM(CASE …)` / `COUNT(CASE …)` compute many filtered aggregates in one pass and pivot rows into columns.
- Keep a total column to detect values your branches don't cover.

**Next:** [05 · Window functions and rankings](05_windows_ranking.md)
