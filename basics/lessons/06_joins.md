# 06 · INNER JOIN relationships

> **You will learn** why data is split across tables, how primary and foreign keys connect them, how to combine tables with `JOIN … ON`, how to chain several joins, and why a one-to-many join repeats rows.
> **Time:** about 50 minutes · **Before this:** [05 · GROUP BY and HAVING](05_group_by_having.md)

An order needs a customer's name, the products' names and their categories. Storing all of that on every order would repeat the same facts hundreds of times and let them drift apart. Instead each fact lives in **one** table, and keys point from one table to another. A **join** follows those pointers.

**Run the whole lesson:** `python tools/run_sql.py basics/lessons/06_joins.sql`

## 1. Keys connect tables

- A **primary key** identifies a row: `customers.customer_id`, `orders.order_id`.
- A **foreign key** stores another table's primary key: `orders.customer_id` says *which* customer placed the order.

```text
customers (customer_id) 1 ───< many  orders (customer_id)
orders    (order_id)    1 ───< many  order_items (order_id) >─── 1 products (product_id)
products  (category_id) many >───  1 categories (category_id)
```

The schema declares these with `REFERENCES`, so the database refuses an order for a customer that doesn't exist.

## 2. JOIN … ON

`JOIN` pairs each row of the left table with the rows of the right table that satisfy the `ON` condition. An **inner** join (plain `JOIN`) keeps only the pairs that match.

```sql
SELECT o.order_id, o.ordered_at, c.full_name, c.city
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'paid'
ORDER BY o.order_id;
```

<!-- result -->
| order_id | ordered_at | full_name | city |
|---|---|---|---|
| 101 | 2026-01-12 | Ana Ionescu | Bucharest |
| 102 | 2026-02-05 | Bogdan Pop | Cluj-Napoca |
| 103 | 2026-03-02 | Ana Ionescu | Bucharest |
| 105 | 2026-04-06 | Darius Ene | Timișoara |
| 107 | 2026-05-04 | Florin Matei | Constanța |
| 109 | 2026-06-02 | Gabriela Dinu | Sibiu |
| 110 | 2026-06-21 | Horia Vlad | Oradea |
| 111 | 2026-07-08 | Carmen Radu | Iași |
<!-- /result -->

- `orders o` gives the table a short **alias**. Prefix every column with it (`o.order_id`) so readers, and the database, know where each column comes from.
- Both tables have a `customer_id` column; without a prefix, `SELECT customer_id` would be *ambiguous* and fail.
- `ON` describes how rows relate; `WHERE` then filters the joined rows.

## 3. Chaining joins

Each `JOIN` adds one more table. To show what each order line was, go from lines to products to categories:

```sql
SELECT i.order_id, p.sku, p.product_name, c.category_name, i.quantity
FROM order_items i
JOIN products p   ON p.product_id = i.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE i.order_id IN (101, 103, 105)
ORDER BY i.order_id, p.sku;
```

<!-- result -->
| order_id | sku | product_name | category_name | quantity |
|---|---|---|---|---|
| 101 | P01 | Notebook | Stationery | 2 |
| 101 | P02 | Pen | Stationery | 3 |
| 103 | P04 | Keyboard | Electronics | 1 |
| 103 | P08 | Mouse | Electronics | 1 |
| 105 | P05 | Desk Lamp | Home | 2 |
| 105 | P06 | Marker | Stationery | 4 |
<!-- /result -->

Joins aren't limited to foreign keys. A **self-join** joins a table to itself, as in lesson 07's employees and managers.

## 4. One-to-many joins repeat rows

Joining a "one" row to its "many" rows repeats the "one" side once per match. Order 101 has two lines, so its customer appears twice:

```sql
SELECT o.order_id, c.full_name, i.product_id, i.quantity
FROM orders o
JOIN customers c   ON c.customer_id = o.customer_id
JOIN order_items i ON i.order_id = o.order_id
WHERE o.customer_id = 1
ORDER BY o.order_id, i.product_id;
```

<!-- result -->
| order_id | full_name | product_id | quantity |
|---|---|---|---|
| 101 | Ana Ionescu | 1 | 2 |
| 101 | Ana Ionescu | 2 | 3 |
| 103 | Ana Ionescu | 4 | 1 |
| 103 | Ana Ionescu | 8 | 1 |
<!-- /result -->

That's correct, because the grain is now *one row per order line*. It becomes a bug when you then count or sum at a different grain. "How many orders does Ana have?" is not `COUNT(*)` over this result (4); it's `COUNT(DISTINCT o.order_id)` (2), or better, counting before you join.

```sql
SELECT c.full_name,
       COUNT(*)                   AS joined_rows,
       COUNT(DISTINCT o.order_id) AS orders,
       SUM(i.quantity * i.unit_price_cents) AS item_cents
FROM orders o
JOIN customers c   ON c.customer_id = o.customer_id
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY c.customer_id, c.full_name
ORDER BY item_cents DESC, c.full_name;
```

<!-- result -->
| full_name | joined_rows | orders | item_cents |
|---|---|---|---|
| Ana Ionescu | 4 | 2 | 25550 |
| Darius Ene | 2 | 1 | 19600 |
| Horia Vlad | 2 | 1 | 16150 |
| Carmen Radu | 2 | 1 | 13800 |
| Gabriela Dinu | 2 | 1 | 11350 |
| Florin Matei | 2 | 1 | 10100 |
| Bogdan Pop | 2 | 1 | 5400 |
<!-- /result -->

The Intermediate level returns to this as **fan-out**, the reason joining two different "many" tables at once inflates totals.

## 5. Joins and aggregates together

Join first to reach the columns you need, then group at the grain you want. Paid revenue per category:

```sql
SELECT c.category_name, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
FROM order_items i
JOIN orders o     ON o.order_id = i.order_id
JOIN products p   ON p.product_id = i.product_id
JOIN categories c ON c.category_id = p.category_id
WHERE o.status = 'paid'
GROUP BY c.category_id, c.category_name
ORDER BY revenue_cents DESC;
```

<!-- result -->
| category_name | revenue_cents |
|---|---|
| Electronics | 44800 |
| Home | 26700 |
| Books | 20800 |
| Stationery | 9650 |
<!-- /result -->

Group by the **key** (`c.category_id`) and the display name together: two categories could share a name, never a key.

## Common mistakes

| Mistake | What happens | Fix |
|---|---|---|
| Forgetting `ON` (or `ON 1 = 1`) | Every left row pairs with every right row (a *cross join*) | Always join on the key |
| Joining on names (`c.full_name = …`) | Duplicates and misses when names repeat or change | Join on IDs |
| Unprefixed columns | `ambiguous column name` error, or confusing queries | Alias every table, prefix every column |
| `COUNT(*)` after a one-to-many join | Counts lines, not orders | `COUNT(DISTINCT key)` or aggregate before joining |
| Expecting an inner join to keep unmatched rows | They disappear | `LEFT JOIN` (lesson 07) |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PB16` | **Products with categories.** Return sku, product_name, category_name for every product, sorted by sku. | query |
| `PB17` | **Who placed each order.** Return order_id, full_name, ordered_at for every order, sorted by order_id. | query |
| `PB42` | **Order city and status.** Return order_id, city (the customer's city), status for every order, sorted by order_id. | query |
| `PB43` | **Staff by team.** Return team_name, full_name for every employee, sorted by team_name then full_name. | query |
| `PB44` | **What was ordered.** Return order_id, sku, quantity for every order line, sorted by order_id then sku. | query |
| `PB45` | **Paid revenue by category name.** Return category_name, revenue_cents (quantity × unit_price_cents of lines in paid orders) for categories with paid sales, sorted by revenue_cents descending, then category_name. | query |

```bash
python tools/practice.py show PB16
python tools/practice.py check PB16
python tools/practice.py hint PB16 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** `orders.customer_id` is…

   - **a)** a foreign key to customers
   - **b)** the primary key of orders
   - **c)** a copy of the customer's name

**2.** What does an inner join do with an order whose customer_id has no match?

   - **a)** Keeps it with NULLs
   - **b)** Drops it
   - **c)** Raises an error

**3.** Customer Ana has 2 orders with 4 lines. After joining orders to order_items, `COUNT(*)` for Ana is…

   - **a)** 2
   - **b)** 4
   - **c)** 1

**4.** Why group by `c.category_id, c.category_name` instead of only the name?

   - **a)** It is faster
   - **b)** Two categories could share a name, never a key
   - **c)** SQLite requires two columns

```bash
python tools/quiz.py basics/06 1 b      # question 1, answer b
python tools/quiz.py basics/06           # list the questions
```
<!-- /quiz -->

## Summary

- Primary keys identify rows; foreign keys point to them.
- `JOIN … ON` combines matching rows; an inner join drops non-matches.
- Alias tables and prefix columns.
- Joining one-to-many repeats the "one" side; aggregate at the grain you mean.

**Next:** [07 · LEFT JOIN and missing data](07_left_join.md)
