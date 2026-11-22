-- Worked example A3 · Rolling revenue up a category tree
-- Examples from advanced/worked_examples/03_tree_rollup.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/worked_examples/03_tree_rollup.sql
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

SELECT parent.name, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
FROM category_tree parent
JOIN category_tree child ON child.parent_id = parent.node_id
JOIN products p ON p.category_id = child.category_id
JOIN order_items i ON i.product_id = p.product_id
JOIN orders o ON o.order_id = i.order_id AND o.status = 'paid'
GROUP BY parent.node_id, parent.name
ORDER BY parent.node_id;

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
