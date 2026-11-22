# 07 · Text, dates, and grouped timelines

> **You will learn** how SQLite stores dates, to format and truncate them with `strftime` and `date`, to do date arithmetic with modifiers and `julianday`, to group by month, quarter and weekday, and to clean and combine text with `TRIM`, `REPLACE`, `INSTR` and `group_concat`.
> **Time:** about 50 minutes · **Before this:** [06 · LAG, LEAD, and running totals](06_windows_running.md)

Dates drive almost every business report ("this month", "last 30 days", "per quarter"), and text needs cleaning before it can be grouped. SQLite has no separate date type; it has a small, powerful set of date functions that work on ISO-8601 text.

**Run the whole lesson:** `python tools/run_sql.py intermediate/lessons/07_dates_strings.sql`

## 1. Dates are ISO text

The sample stores dates as `YYYY-MM-DD` text. That format sorts and compares correctly as text, and every SQLite date function understands it.

```sql
SELECT date('2026-03-12')                 AS d,
       strftime('%Y', '2026-03-12')        AS year,
       strftime('%m', '2026-03-12')        AS month,
       strftime('%d', '2026-03-12')        AS day,
       strftime('%w', '2026-03-12')        AS weekday_0_sunday,
       strftime('%j', '2026-03-12')        AS day_of_year,
       strftime('%Y-%m', '2026-03-12')     AS year_month;
```

<!-- result -->
| d | year | month | day | weekday_0_sunday | day_of_year | year_month |
|---|---|---|---|---|---|---|
| 2026-03-12 | 2026 | 03 | 12 | 4 | 071 | 2026-03 |
<!-- /result -->

`strftime` returns **text**. Compare it with text (`= '03'`) or `CAST` it to an integer for arithmetic.

## 2. Date arithmetic

`date(value, modifier, …)` applies **modifiers** in order:

```sql
SELECT date('2026-01-31', '+1 month')                 AS plus_one_month,
       date('2026-03-12', '+7 days')                   AS plus_week,
       date('2026-03-12', 'start of month')            AS month_start,
       date('2026-03-12', 'start of month', '+1 month', '-1 day') AS month_end,
       julianday('2026-03-12') - julianday('2026-02-10') AS days_between;
```

<!-- result -->
| plus_one_month | plus_week | month_start | month_end | days_between |
|---|---|---|---|---|
| 2026-03-03 | 2026-03-19 | 2026-03-01 | 2026-03-31 | 30.0 |
<!-- /result -->

- `'+1 month'` on January 31 gives **March 3**: SQLite normalises "February 31". Month arithmetic at month ends is a classic bug in every database, so test it.
- `julianday()` returns a day number, so subtracting two of them gives days (as a real number; `CAST … AS INTEGER` for whole days).
- `'now'` is the current UTC time: `date('now')`. Reports that use it give different answers on different days, so prefer a fixed "as of" date in tests.

## 3. Grouping by period

Truncate each date to the period, then group by it:

```sql
SELECT strftime('%Y', ordered_at) || '-Q' || ((CAST(strftime('%m', ordered_at) AS INTEGER) + 2) / 3) AS quarter,
       COUNT(*) AS orders,
       SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) AS paid
FROM orders
GROUP BY quarter
ORDER BY quarter;
```

<!-- result -->
| quarter | orders | paid |
|---|---|---|
| 2026-Q1 | 4 | 3 |
| 2026-Q2 | 6 | 4 |
| 2026-Q3 | 1 | 1 |
<!-- /result -->

`(month + 2) / 3` maps months 1–3 to 1, 4–6 to 2 and so on, using integer division.

By weekday, with a readable label:

```sql
SELECT CASE strftime('%w', ordered_at)
         WHEN '0' THEN 'Sun' WHEN '1' THEN 'Mon' WHEN '2' THEN 'Tue' WHEN '3' THEN 'Wed'
         WHEN '4' THEN 'Thu' WHEN '5' THEN 'Fri' ELSE 'Sat' END AS weekday,
       COUNT(*) AS orders
FROM orders
GROUP BY strftime('%w', ordered_at)
ORDER BY strftime('%w', ordered_at);
```

<!-- result -->
| weekday | orders |
|---|---|
| Sun | 1 |
| Mon | 4 |
| Tue | 1 |
| Wed | 2 |
| Thu | 3 |
<!-- /result -->

## 4. Ranges: "last 30 days" done right

Filter a period with a **half-open range** `>= start AND < next_start`. It works for dates *and* timestamps, and never double-counts the boundary:

```sql
SELECT order_id, ordered_at
FROM orders
WHERE ordered_at >= '2026-06-01' AND ordered_at < date('2026-06-01', '+1 month')
ORDER BY ordered_at;
```

<!-- result -->
| order_id | ordered_at |
|---|---|
| 109 | 2026-06-02 |
| 110 | 2026-06-21 |
<!-- /result -->

`BETWEEN '2026-06-01' AND '2026-06-30'` would miss `'2026-06-30 14:00'` if the column held timestamps. The half-open form has no such gap.

**Time zones.** The sample uses dates without times. Real systems store **instants** in UTC (`2026-06-30T22:30:00Z`) and convert to the business's local calendar only when grouping by day or month. A sale at 23:30 in Bucharest is already the next day in UTC. Decide which calendar a report uses, and write it down.

## 5. Text cleaning and combining

Grouping by text only works when equal things are spelled equally. Typical clean-up:

```sql
SELECT TRIM('  Cluj-Napoca ')                       AS trimmed,
       LOWER('ANA@Example.TEST')                     AS normalised_email,
       REPLACE('P-01', '-', '')                      AS no_dash,
       SUBSTR('ana@example.test', 1, INSTR('ana@example.test', '@') - 1) AS local_part,
       printf('%05d', 42)                            AS zero_padded;
```

<!-- result -->
| trimmed | normalised_email | no_dash | local_part | zero_padded |
|---|---|---|---|---|
| Cluj-Napoca | ana@example.test | P01 | ana | 00042 |
<!-- /result -->

`group_concat(x, separator)` joins the values of a group into one string, which is handy for compact reports:

```sql
SELECT o.order_id, group_concat(p.sku, ', ') AS skus
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
JOIN products p ON p.product_id = i.product_id
WHERE o.status = 'paid'
GROUP BY o.order_id
ORDER BY o.order_id;
```

<!-- result -->
| order_id | skus |
|---|---|
| 101 | P01, P02 |
| 102 | P02, P03 |
| 103 | P04, P08 |
| 105 | P05, P06 |
| 107 | P01, P08 |
| 109 | P07, P09 |
| 110 | P02, P04 |
| 111 | P03, P05 |
<!-- /result -->

The order of values inside `group_concat` isn't guaranteed. SQLite 3.44+ accepts `group_concat(p.sku, ', ' ORDER BY p.sku)`, and PostgreSQL uses `string_agg(…, ', ' ORDER BY …)`.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Dates stored as `DD/MM/YYYY` text | Sorting and ranges are wrong | Store ISO-8601 |
| `BETWEEN` on timestamps | Last day mostly missing | Half-open range `>= start AND < next` |
| Comparing `strftime('%m', d) = 3` | Never true (`'03'` is text) | `= '03'` or `CAST(… AS INTEGER) = 3` |
| `'+1 month'` at month end | Jumps into the following month | Test month-end cases; use `start of month` |
| Grouping uncleaned text | `' Cluj'` and `'Cluj'` as separate groups | `TRIM`/`LOWER` before grouping, or better, clean on write |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PI14` | **Signup month.** Return customer_id, signup_month (joined_at formatted as YYYY-MM) for every customer, sorted by customer_id. | query |
| `PI15` | **Orders long after signup.** Return order_id, customer_id, days_after_signup (whole days between joined_at and ordered_at, as an integer) for orders placed more than 7 days after the customer joined. Sort by order_id. | query |
| `PI39` | **Orders per quarter.** Return quarter (text like '2026-Q1') and orders (count of orders, any status) per quarter of ordered_at. Sort by quarter. | query |
| `PI40` | **Orders by weekday.** Return weekday (0 = Sunday … 6 = Saturday, as an integer) and orders (count, any status) for weekdays that have orders. Sort by weekday. | query |
| `PI41` | **Orders in June.** Return order_id, ordered_at for orders placed in June 2026, using a half-open date range. Sort by ordered_at, then order_id. | query |
| `PI42` | **Email local parts.** Return customer_id and local_part (the part of the email before '@') for every customer, sorted by customer_id. | query |

```bash
python tools/practice.py show PI14
python tools/practice.py check PI14
python tools/practice.py hint PI14 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** Which filter covers all of June 2026, even for timestamps?

   - **a)** BETWEEN '2026-06-01' AND '2026-06-30'
   - **b)** >= '2026-06-01' AND < '2026-07-01'
   - **c)** LIKE '2026-06'

**2.** `strftime('%m', '2026-03-12') = 3` is…

   - **a)** true
   - **b)** false, because strftime returns the text '03'
   - **c)** an error

**3.** What is `date('2026-01-31', '+1 month')` in SQLite?

   - **a)** 2026-02-28
   - **b)** 2026-03-03
   - **c)** NULL

**4.** How do you get the number of days between two ISO dates?

   - **a)** d2 - d1
   - **b)** julianday(d2) - julianday(d1)
   - **c)** strftime('%d', d2 - d1)

```bash
python tools/quiz.py intermediate/07 1 b      # question 1, answer b
python tools/quiz.py intermediate/07           # list the questions
```
<!-- /quiz -->

## Summary

- Store dates as ISO-8601 text; `strftime` formats, `date` applies modifiers, `julianday` subtracts.
- Group by a truncated period (`%Y-%m`, quarter, weekday).
- Filter periods with half-open ranges; decide the time zone of the business calendar.
- Clean text with `TRIM`, `LOWER`, `REPLACE`; combine with `group_concat`.

**Next:** [08 · UNION, INTERSECT, EXCEPT](08_set_operations.md)
