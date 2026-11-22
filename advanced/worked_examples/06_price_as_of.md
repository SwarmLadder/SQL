# Worked example A6 · Prices as of a date

**Problem.** Products change price over time. Analysts ask: "What was the list price of each product **on the day each order was placed**, and did any order line get charged something different?"

**Run:** `python tools/run_sql.py advanced/worked_examples/06_price_as_of.sql`

## 1. Plan

Keep history in its own table, one row per price period, starting at `valid_from`:

```sql
CREATE TABLE price_history (
  product_id INTEGER NOT NULL REFERENCES products(product_id),
  valid_from TEXT NOT NULL,
  price_cents INTEGER NOT NULL CHECK (price_cents >= 0),
  PRIMARY KEY (product_id, valid_from)
);
INSERT INTO price_history VALUES
  (4, '2026-01-01', 15900), (4, '2026-05-01', 14900),
  (8, '2026-01-01', 6500),
  (5, '2026-01-01', 8900),  (5, '2026-04-10', 9900);
```

<!-- result -->
*Rows changed: 5*
<!-- /result -->

The price valid on date *d* is the row with the **latest `valid_from` ≤ d**.

## 2. Tempting attempt: join on a range that doesn't exist

```sql
SELECT i.order_id, i.product_id, o.ordered_at, h.price_cents
FROM order_items i
JOIN orders o ON o.order_id = i.order_id
JOIN price_history h ON h.product_id = i.product_id AND h.valid_from <= o.ordered_at
WHERE i.product_id IN (4, 5)
ORDER BY i.order_id, h.valid_from;
```

<!-- result -->
| order_id | product_id | ordered_at | price_cents |
|---|---|---|---|
| 103 | 4 | 2026-03-02 | 15900 |
| 105 | 5 | 2026-04-06 | 8900 |
| 110 | 4 | 2026-06-21 | 15900 |
| 110 | 4 | 2026-06-21 | 14900 |
| 111 | 5 | 2026-07-08 | 8900 |
| 111 | 5 | 2026-07-08 | 9900 |
<!-- /result -->

Every earlier price matches too: order 110 (June) pairs with both the January and the May keyboard price. Without a `valid_to`, `<=` alone matches all past periods.

## 3. Fix: pick the latest period per line

Number the matching periods newest-first and keep number 1:

```sql
WITH matches AS (
  SELECT i.order_id, i.product_id, o.ordered_at, i.unit_price_cents AS charged_cents,
         h.price_cents AS list_cents,
         ROW_NUMBER() OVER (PARTITION BY i.order_id, i.product_id ORDER BY h.valid_from DESC) AS rn
  FROM order_items i
  JOIN orders o ON o.order_id = i.order_id
  JOIN price_history h ON h.product_id = i.product_id AND h.valid_from <= o.ordered_at
)
SELECT order_id, product_id, ordered_at, list_cents, charged_cents,
       CASE WHEN list_cents = charged_cents THEN 'ok' ELSE 'differs' END AS check_result
FROM matches
WHERE rn = 1
ORDER BY order_id, product_id;
```

<!-- result -->
| order_id | product_id | ordered_at | list_cents | charged_cents | check_result |
|---|---|---|---|---|---|
| 103 | 4 | 2026-03-02 | 15900 | 15900 | ok |
| 103 | 8 | 2026-03-02 | 6500 | 6500 | ok |
| 105 | 5 | 2026-04-06 | 8900 | 8900 | ok |
| 107 | 8 | 2026-05-04 | 6500 | 6500 | ok |
| 110 | 4 | 2026-06-21 | 14900 | 15900 | differs |
| 111 | 5 | 2026-07-08 | 9900 | 8900 | differs |
<!-- /result -->

Two lines differ. Order 110 bought a keyboard in June, when the list price was 14 900, but was charged 15 900. Order 111 bought a desk lamp in July at the old 8 900, after the April 10 rise to 9 900. Order 105's desk lamps (April 6, before the rise) were charged correctly. Whether a difference is a bug or an agreed discount is now a question for the business, and the query made it visible.

## 4. Alternatives and tests

- **Correlated subquery:** `(SELECT price_cents FROM price_history h WHERE h.product_id = i.product_id AND h.valid_from <= o.ordered_at ORDER BY h.valid_from DESC LIMIT 1)`. It's clear, and with the primary key `(product_id, valid_from)` it's an index lookup per line.
- **Store `valid_to`** (computed with `LEAD(valid_from)`) to make the join a simple `BETWEEN`-style range, at the price of keeping it consistent.
- Test: a date exactly on `valid_from`, a date before the first period (no price: decide what that means), and a product with one period.

**Practise next:** [PA30](../../practice/starter/PA30.sql), [PI35](../../practice/starter/PI35.sql).
