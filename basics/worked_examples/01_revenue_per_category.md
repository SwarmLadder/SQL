# Worked example B1 · Revenue per category, keeping empty categories

**Problem.** Report paid revenue for *every* category, with 0 for categories that sold nothing.

**Run:** `python tools/run_sql.py basics/worked_examples/01_revenue_per_category.sql`

## 1. Plan before typing

| Question | Answer |
|---|---|
| One output row per… | category, so `categories` is the driving table |
| Where does revenue live? | `order_items.quantity × order_items.unit_price_cents` |
| Which lines count? | lines of **paid** orders |
| Which rows might be missing? | categories with no products, products with no sales |

Missing rows mean `LEFT JOIN` from `categories`.

## 2. First attempt and why it fails

```sql norun
... LEFT JOIN orders o ON o.order_id = i.order_id
WHERE o.status = 'paid'
```

For a category with no sales every right-hand column is `NULL`, so `o.status = 'paid'` is unknown and `WHERE` drops the row. **A `WHERE` condition on the right table of a `LEFT JOIN` turns it back into an inner join.** The script adds an empty `Garden` category and it vanishes from attempt 1.

## 3. Fix

Keep every row and decide *inside the aggregate* which lines count:

```sql norun
COALESCE(SUM(CASE WHEN o.status = 'paid' THEN i.quantity * i.unit_price_cents END), 0)
```

`CASE` without `ELSE` yields `NULL` for unpaid lines; `SUM` ignores `NULL`; `COALESCE` turns the "nothing at all" `NULL` into `0`. Moving `o.status = 'paid'` into the `ON` clause of the orders join would also work, but then unpaid lines still survive the earlier joins, which is easier to get wrong.

## 4. Test it

| Case | Expected | Result |
|---|---|---|
| Category with paid sales | its total | Books 20800 ✅ |
| Category with no products | 0 | Garden 0 ✅ |
| Grand total equals paid line total | 101 950 | ✅ (20800 + 44800 + 26700 + 9650) |

**Practise next:** [PB19](../../practice/starter/PB19.sql), [PI05](../../practice/starter/PI05.sql).
