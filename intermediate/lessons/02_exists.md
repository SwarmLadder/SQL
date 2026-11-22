# 02 · EXISTS and correlated subqueries

> **You will learn** to ask yes/no questions about related rows with `EXISTS` and `NOT EXISTS`, why they never duplicate rows and never fall into the `NULL` trap, and how they compare with `IN` and `LEFT JOIN … IS NULL`.
> **Time:** about 45 minutes · **Before this:** [01 · Subqueries](01_subqueries.md)

Many questions are really about *existence*: "customers who have **ever** paid", "products that **no** paid order contains", "teams **without** employees". `EXISTS` asks exactly that, once per outer row, and stops at the first match.

**Run the whole lesson:** `python tools/run_sql.py intermediate/lessons/02_exists.sql`

## 1. EXISTS: is there at least one?

`EXISTS (subquery)` is true when the subquery returns at least one row. What it selects doesn't matter, so the convention is `SELECT 1`.

```sql
SELECT c.customer_id, c.full_name
FROM customers c
WHERE EXISTS (SELECT 1
              FROM orders o
              WHERE o.customer_id = c.customer_id
                AND o.status = 'pending')
ORDER BY c.customer_id;
```

<!-- result -->
| customer_id | full_name |
|---|---|
| 2 | Bogdan Pop |
| 3 | Carmen Radu |
<!-- /result -->

- The subquery is **correlated**: `c.customer_id` is the current outer customer.
- Each customer appears once, however many pending orders they have. This kind of query is a **semi-join**.
- Compare with a join: `JOIN orders … WHERE status = 'pending'` would list a customer once per pending order and need `DISTINCT`.

## 2. NOT EXISTS: there is none

`NOT EXISTS` keeps outer rows with **no** matching row: an *anti-join*.

```sql
SELECT p.sku, p.product_name
FROM products p
WHERE NOT EXISTS (SELECT 1
                  FROM order_items i
                  JOIN orders o ON o.order_id = i.order_id
                  WHERE i.product_id = p.product_id
                    AND o.status = 'paid')
ORDER BY p.sku;
```

<!-- result -->
| sku | product_name |
|---|---|
| *(no rows)* |  |
<!-- /result -->

Every product has been sold in some paid order in the sample data. Add a product that only appears in a cancelled order and run it again:

```sql
BEGIN;
INSERT INTO products VALUES (30, 'P30', 1, 'Unsold Atlas', 3000, 1);
INSERT INTO order_items VALUES (106, 30, 1, 3000);

SELECT p.sku, p.product_name
FROM products p
WHERE NOT EXISTS (SELECT 1
                  FROM order_items i
                  JOIN orders o ON o.order_id = i.order_id
                  WHERE i.product_id = p.product_id
                    AND o.status = 'paid')
ORDER BY p.sku;

ROLLBACK;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 1*

| sku | product_name |
|---|---|
| P30 | Unsold Atlas |
<!-- /result -->

The extra condition `o.status = 'paid'` lives **inside** the subquery. "Not sold in a *paid* order" is different from "never ordered".

## 3. Why NOT EXISTS beats NOT IN

`EXISTS` only ever returns true or false, never unknown, so `NULL`s can't empty your result. Lesson 01's "employees who manage nobody" becomes:

```sql
SELECT e.full_name
FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM employees r WHERE r.manager_id = e.employee_id)
ORDER BY e.employee_id;
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

No `IS NOT NULL` guard is needed: the `NULL` manager IDs simply never equal anyone's ID.

## 4. Three ways to write an anti-join

| Pattern | Duplicates? | NULL-safe? | Notes |
|---|---|---|---|
| `WHERE NOT EXISTS (… correlated …)` | never | yes | Clearest intent; usually the best default |
| `LEFT JOIN … WHERE right.key IS NULL` | never (if the key is tested) | yes | Same result; handy when you also need right-side columns |
| `WHERE x NOT IN (SELECT …)` | never | **no** | Only safe if the subquery column is `NOT NULL` |

Modern optimisers usually run `NOT EXISTS` and the `LEFT JOIN` form the same way. Choose the one that states the question most clearly.

## 5. EXISTS with several conditions

The subquery can test anything about the related rows. "Customers who placed an order within 30 days of joining":

```sql
SELECT c.full_name, c.joined_at
FROM customers c
WHERE EXISTS (SELECT 1
              FROM orders o
              WHERE o.customer_id = c.customer_id
                AND julianday(o.ordered_at) - julianday(c.joined_at) <= 30)
ORDER BY c.customer_id;
```

<!-- result -->
| full_name | joined_at |
|---|---|
| Ana Ionescu | 2026-01-05 |
| Bogdan Pop | 2026-01-15 |
| Carmen Radu | 2026-02-10 |
<!-- /result -->

`julianday` turns a date into a day number so dates can be subtracted. Lesson 07 covers it.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Forgetting the correlation (`WHERE o.customer_id = c.customer_id`) | EXISTS is true for every row, or none | Always link the subquery to the outer row |
| Putting the extra filter outside the subquery | Answers a different question | Conditions about the related rows go inside |
| `JOIN` instead of `EXISTS` for "has any" | Duplicated outer rows | Use `EXISTS`, or `DISTINCT` if you must join |
| `NOT IN` over nullable data | Empty result | `NOT EXISTS` |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PI04` | **Customers who paid.** Using EXISTS, return customer_id, full_name for customers with at least one paid order, sorted by customer_id. | query |
| `PI05` | **Products nobody paid for.** Using NOT EXISTS, return sku, product_name for products that do not appear in any paid order, sorted by sku. | query |
| `PI19` | **No paid order yet.** Return customer_id, full_name for customers with no paid order, including customers with no orders at all. Sort by customer_id. | query |
| `PI26` | **Teams without employees.** Using NOT EXISTS, return team_id, team_name for teams with no employees, sorted by team_id. | query |
| `PI27` | **Quick first orders.** Return customer_id, full_name for customers who placed any order within 30 days of joining (at most 30 days after joined_at), sorted by customer_id. | query |

```bash
python tools/practice.py show PI04
python tools/practice.py check PI04
python tools/practice.py hint PI04 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** What does the subquery of EXISTS usually select?

   - **a)** SELECT 1, because only existence matters
   - **b)** SELECT * for correctness
   - **c)** The primary key

**2.** A customer has three pending orders. `WHERE EXISTS (…pending…)` returns them…

   - **a)** three times
   - **b)** once
   - **c)** not at all

**3.** Why is NOT EXISTS safer than NOT IN?

   - **a)** It's faster in every database
   - **b)** It's never unknown, so NULLs can't empty the result
   - **c)** It allows ORDER BY

**4.** Where does the condition `o.status = 'paid'` go in "products not in any paid order"?

   - **a)** Inside the NOT EXISTS subquery
   - **b)** In the outer WHERE
   - **c)** In ORDER BY

```bash
python tools/quiz.py intermediate/02 1 b      # question 1, answer b
python tools/quiz.py intermediate/02           # list the questions
```
<!-- /quiz -->

## Summary

- `EXISTS` asks "is there at least one related row?"; `NOT EXISTS` asks "is there none?".
- They never duplicate outer rows and are never unknown, so they are safe with `NULL`.
- Correlate the subquery to the outer row and put related-row conditions inside it.
- Prefer `NOT EXISTS` over `NOT IN` for anti-joins.

**Next:** [03 · Common table expressions](03_cte.md)
