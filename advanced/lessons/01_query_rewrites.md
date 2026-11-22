# 01 · Query rewrites and correct grain

> **You will learn** to rewrite queries into faster or clearer equivalents (correlated subquery → aggregate join, `EXISTS` ↔ `JOIN`, `OR` → `UNION ALL`, `OFFSET` → keyset pagination) and, above all, to **prove** that a rewrite returns the same rows.
> **Time:** about 55 minutes · **Before this:** [00 · Indexes and query plans](00_indexes_explain.md), [Intermediate 08 · set operations](../../intermediate/lessons/08_set_operations.md)

Two queries are only interchangeable under stated assumptions: same duplicates, same `NULL` handling, same rows for empty groups. A rewrite that's faster but wrong is a bug with good performance. This lesson pairs every rewrite with a check.

**Run the whole lesson:** `python tools/run_sql.py advanced/lessons/01_query_rewrites.sql`

## 1. The rewrite workflow

1. Write down what the query must return: grain, filters, `NULL` and empty-group behaviour.
2. Write the rewrite.
3. **Compare results** on data that includes edge cases: `EXCEPT` both ways, plus row counts.
4. Compare plans (`EXPLAIN QUERY PLAN`) and, on realistic data, timings.

## 2. Correlated subqueries → one aggregate

Two correlated subqueries run once per customer each:

```sql
SELECT c.customer_id,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) AS order_count,
       (SELECT MAX(ordered_at) FROM orders o WHERE o.customer_id = c.customer_id) AS last_order
FROM customers c
ORDER BY c.customer_id;
```

<!-- result -->
| customer_id | order_count | last_order |
|---|---|---|
| 1 | 2 | 2026-03-02 |
| 2 | 2 | 2026-05-14 |
| 3 | 2 | 2026-07-08 |
| 4 | 1 | 2026-04-06 |
| 5 | 1 | 2026-04-15 |
| 6 | 1 | 2026-05-04 |
| 7 | 1 | 2026-06-02 |
| 8 | 1 | 2026-06-21 |
<!-- /result -->

The set-based version aggregates `orders` **once** and joins the result:

```sql
WITH stats AS (
  SELECT customer_id, COUNT(*) AS order_count, MAX(ordered_at) AS last_order
  FROM orders
  GROUP BY customer_id
)
SELECT c.customer_id, COALESCE(s.order_count, 0) AS order_count, s.last_order
FROM customers c
LEFT JOIN stats s ON s.customer_id = c.customer_id
ORDER BY c.customer_id;
```

<!-- result -->
| customer_id | order_count | last_order |
|---|---|---|
| 1 | 2 | 2026-03-02 |
| 2 | 2 | 2026-05-14 |
| 3 | 2 | 2026-07-08 |
| 4 | 1 | 2026-04-06 |
| 5 | 1 | 2026-04-15 |
| 6 | 1 | 2026-05-04 |
| 7 | 1 | 2026-06-02 |
| 8 | 1 | 2026-06-21 |
<!-- /result -->

The `LEFT JOIN` and `COALESCE(…, 0)` are what make it *equivalent*: the correlated `COUNT(*)` returns 0 for a customer without orders, while an inner join would drop them. Check with `EXCEPT` both ways:

```sql
WITH a AS (
  SELECT c.customer_id,
         (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) AS order_count,
         (SELECT MAX(ordered_at) FROM orders o WHERE o.customer_id = c.customer_id) AS last_order
  FROM customers c
), b AS (
  SELECT c.customer_id, COALESCE(s.order_count, 0) AS order_count, s.last_order
  FROM customers c
  LEFT JOIN (SELECT customer_id, COUNT(*) AS order_count, MAX(ordered_at) AS last_order
             FROM orders GROUP BY customer_id) s ON s.customer_id = c.customer_id
)
SELECT (SELECT COUNT(*) FROM (SELECT * FROM a EXCEPT SELECT * FROM b)) AS only_in_a,
       (SELECT COUNT(*) FROM (SELECT * FROM b EXCEPT SELECT * FROM a)) AS only_in_b,
       (SELECT COUNT(*) FROM a) AS rows_a,
       (SELECT COUNT(*) FROM b) AS rows_b;
```

<!-- result -->
| only_in_a | only_in_b | rows_a | rows_b |
|---|---|---|---|
| 0 | 0 | 8 | 8 |
<!-- /result -->

## 3. EXISTS ↔ JOIN: watch the duplicates

`EXISTS` returns each customer once. A join returns a customer once **per matching order**, so it needs `DISTINCT` to be equivalent:

```sql
SELECT (SELECT COUNT(*) FROM customers c
        WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id AND o.status = 'paid')) AS exists_rows,
       (SELECT COUNT(*) FROM customers c
        JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'paid') AS join_rows,
       (SELECT COUNT(DISTINCT c.customer_id) FROM customers c
        JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'paid') AS join_distinct_rows;
```

<!-- result -->
| exists_rows | join_rows | join_distinct_rows |
|---|---|---|
| 7 | 8 | 7 |
<!-- /result -->

Ana has two paid orders, so the plain join has one extra row. `DISTINCT` fixes it, but only if the selected columns identify the customer. `SELECT DISTINCT c.full_name` would merge two different customers who share a name.

## 4. OR across columns → UNION ALL

An `OR` on two different indexed columns can force a scan. Splitting it into two indexable queries and combining them can be faster, as long as you avoid counting a row twice:

```sql
SELECT order_id FROM orders WHERE customer_id = 2 OR status = 'cancelled'
ORDER BY order_id;
```

<!-- result -->
| order_id |
|---|
| 102 |
| 106 |
| 108 |
<!-- /result -->

```sql
SELECT order_id FROM orders WHERE customer_id = 2
UNION ALL
SELECT order_id FROM orders WHERE status = 'cancelled' AND customer_id <> 2
ORDER BY order_id;
```

<!-- result -->
| order_id |
|---|
| 102 |
| 106 |
| 108 |
<!-- /result -->

The second branch excludes rows the first already returned (`customer_id <> 2`). That works here because `customer_id` is `NOT NULL`; for a nullable column you'd write `(col <> 2 OR col IS NULL)`. Plain `UNION` also de-duplicates, but it sorts or hashes everything to do it.

## 5. OFFSET → keyset pagination

`LIMIT 20 OFFSET 100000` reads and throws away 100 000 rows, and rows shift between pages when data changes. **Keyset** pagination remembers the last row of the previous page and continues after it:

```sql
SELECT order_id, ordered_at FROM orders
ORDER BY ordered_at, order_id
LIMIT 4;
```

<!-- result -->
| order_id | ordered_at |
|---|---|
| 101 | 2026-01-12 |
| 102 | 2026-02-05 |
| 103 | 2026-03-02 |
| 104 | 2026-03-12 |
<!-- /result -->

Page 2 starts after the last row shown (`2026-03-12`, order 104):

```sql
SELECT order_id, ordered_at FROM orders
WHERE (ordered_at, order_id) > ('2026-03-12', 104)
ORDER BY ordered_at, order_id
LIMIT 4;
```

<!-- result -->
| order_id | ordered_at |
|---|---|
| 105 | 2026-04-06 |
| 106 | 2026-04-15 |
| 107 | 2026-05-04 |
| 108 | 2026-05-14 |
<!-- /result -->

- The sort must be **unique** (`ordered_at, order_id`), and the `WHERE` must use the same columns in the same order.
- Row-value comparisons `(a, b) > (x, y)` work in SQLite 3.15+ and PostgreSQL. With an index on `(ordered_at, order_id)`, each page costs the same however deep you go.
- Trade-off: no "jump to page 37". Clients go forward (or back) from a cursor.

## 6. Rewrites that are *not* equivalent

| Rewrite | Breaks when |
|---|---|
| `NOT IN (subquery)` ← `NOT EXISTS` | the subquery column contains NULL |
| `JOIN` ← `EXISTS` | a match occurs more than once (duplicates) |
| `INNER JOIN` summary ← correlated `COUNT` | an entity has no rows (missing instead of 0) |
| `UNION` ← `UNION ALL` | genuine duplicates must be kept |
| `COUNT(col)` ← `COUNT(*)` | `col` is nullable |

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Checking a rewrite on happy-path data only | Breaks on NULLs, empties, duplicates | Test with an edge-case fixture |
| `EXCEPT` in one direction | Missed extra rows | Both directions plus row counts |
| `DISTINCT` on a non-unique display column | Different entities merged | `DISTINCT` on the key |
| Keyset `WHERE` not matching the `ORDER BY` | Skipped or repeated rows | Same columns, same order, unique sort |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PA03` | **EXISTS rewritten as a JOIN.** Return customer_id, full_name for customers who bought at least one product from the Books category (any order status). Write it with JOINs, not EXISTS, without returning a customer twice. Sort by customer_id. | query |
| `PA04` | **Correlated subquery to aggregate CTE.** Return customer_id, order_count and last_ordered_at for every customer (0 and NULL for customers without orders), computed with one aggregate CTE joined back to customers rather than two correlated subqueries. Sort by customer_id. | query |
| `PA22` | **Keyset page 2.** Orders are listed by ordered_at, then order_id, four per page. Page 1 ended with ('2026-03-12', 104). Using keyset pagination (no OFFSET), return order_id, ordered_at for page 2. | query |
| `PA23` | **OR rewritten as UNION ALL.** Return order_id for orders of customer 2 or with status 'cancelled', each once, sorted by order_id, written as two queries combined with UNION ALL (not UNION, not OR). | query |

```bash
python tools/practice.py show PA03
python tools/practice.py check PA03
python tools/practice.py hint PA03 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** Rewriting a correlated COUNT as an aggregate with an INNER JOIN loses…

   - **a)** entities with zero rows
   - **b)** duplicates
   - **c)** nothing

**2.** Replacing EXISTS with a JOIN requires…

   - **a)** DISTINCT on the key, because a JOIN repeats rows per match
   - **b)** a GROUP BY on every column
   - **c)** nothing

**3.** Why is keyset pagination better than a deep OFFSET?

   - **a)** Each page costs the same, and rows don't shift between pages
   - **b)** It allows jumping to any page
   - **c)** It needs no ORDER BY

**4.** How do you prove two queries return the same rows?

   - **a)** EXCEPT both ways, plus row counts
   - **b)** Compare the first row
   - **c)** Compare their plans

```bash
python tools/quiz.py advanced/01 1 b      # question 1, answer b
python tools/quiz.py advanced/01           # list the questions
```
<!-- /quiz -->

## Summary

- A rewrite is correct only if it returns the same rows, including duplicates, NULLs and empty groups.
- Replace repeated correlated subqueries with one aggregate plus `LEFT JOIN … COALESCE`.
- `EXISTS` → `JOIN` needs `DISTINCT` on the key; `OR` → `UNION ALL` needs a guard against double-counting.
- Keyset pagination replaces deep `OFFSET`s with `WHERE (sort keys) > (last seen)`.
- Prove equivalence with `EXCEPT` both ways and row counts.

**Next:** [02 · Recursive CTEs and hierarchies](02_recursive_cte.md)
