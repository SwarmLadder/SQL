# Worked example A3 · Rolling revenue up a category tree

**Problem.** The shop is reorganising its catalogue into a tree (Books → Programming Books, Office → Stationery …). Management wants revenue **per node including everything below it**.

**Run:** `python tools/run_sql.py advanced/worked_examples/03_tree_rollup.sql`

## 1. Plan

Model the tree with a parent pointer, attach the existing categories as leaves, and give each leaf its direct revenue:

```sql
CREATE TABLE category_tree (
  node_id   INTEGER PRIMARY KEY,
  name      TEXT NOT NULL,
  parent_id INTEGER REFERENCES category_tree(node_id),
  category_id INTEGER REFERENCES categories(category_id)   -- set for leaves only
);
INSERT INTO category_tree VALUES
  (1, 'All products', NULL, NULL),
  (2, 'Office',       1,    NULL),
  (3, 'Tech',         1,    NULL),
  (10, 'Books',       1,    1),
  (11, 'Stationery',  2,    2),
  (12, 'Electronics', 3,    3),
  (13, 'Home',        2,    4);
```

<!-- result -->
*Rows changed: 7*
<!-- /result -->

## 2. Tempting attempt: one self-join

```sql
SELECT parent.name, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
FROM category_tree parent
JOIN category_tree child ON child.parent_id = parent.node_id
JOIN products p ON p.category_id = child.category_id
JOIN order_items i ON i.product_id = p.product_id
JOIN orders o ON o.order_id = i.order_id AND o.status = 'paid'
GROUP BY parent.node_id, parent.name
ORDER BY parent.node_id;
```

<!-- result -->
| name | revenue_cents |
|---|---|
| All products | 20800 |
| Office | 36350 |
| Tech | 44800 |
<!-- /result -->

It only reaches **one level** down. "All products" sees Books (a direct child) but not Stationery, Electronics or Home, which are grandchildren. Any fixed number of joins breaks as soon as the tree gets one level deeper.

## 3. Fix: pair every node with all of its descendants

A recursive CTE builds every (ancestor, descendant) pair, including each node paired with itself. Then join descendants to their revenue and group by ancestor:

```sql
WITH RECURSIVE closure(ancestor_id, descendant_id) AS (
  SELECT node_id, node_id FROM category_tree
  UNION ALL
  SELECT c.ancestor_id, t.node_id
  FROM closure c
  JOIN category_tree t ON t.parent_id = c.descendant_id
),
leaf_revenue AS (
  SELECT t.node_id, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM category_tree t
  JOIN products p    ON p.category_id = t.category_id
  JOIN order_items i ON i.product_id = p.product_id
  JOIN orders o      ON o.order_id = i.order_id AND o.status = 'paid'
  GROUP BY t.node_id
)
SELECT a.node_id, a.name, COALESCE(SUM(r.revenue_cents), 0) AS rollup_cents
FROM closure c
JOIN category_tree a ON a.node_id = c.ancestor_id
LEFT JOIN leaf_revenue r ON r.node_id = c.descendant_id
GROUP BY a.node_id, a.name
ORDER BY a.node_id;
```

<!-- result -->
| node_id | name | rollup_cents |
|---|---|---|
| 1 | All products | 101950 |
| 2 | Office | 36350 |
| 3 | Tech | 44800 |
| 10 | Books | 20800 |
| 11 | Stationery | 9650 |
| 12 | Electronics | 44800 |
| 13 | Home | 26700 |
<!-- /result -->

## 4. Test it

| Check | Expected |
|---|---|
| Root equals total paid revenue | "All products" = 101 950 |
| A parent equals the sum of its children | Office = Stationery + Home = 9 650 + 26 700 |
| A leaf equals its own revenue | Electronics = 44 800 |

The `closure` CTE is a **closure table** computed on the fly. Large systems often store it permanently and maintain it on writes, so reads need no recursion.

**Practise next:** [PA25](../../practice/starter/PA25.sql), [PA05](../../practice/starter/PA05.sql).
