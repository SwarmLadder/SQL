-- Worked example A6 · Prices as of a date
-- Examples from advanced/worked_examples/06_price_as_of.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/worked_examples/06_price_as_of.sql
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

SELECT i.order_id, i.product_id, o.ordered_at, h.price_cents
FROM order_items i
JOIN orders o ON o.order_id = i.order_id
JOIN price_history h ON h.product_id = i.product_id AND h.valid_from <= o.ordered_at
WHERE i.product_id IN (4, 5)
ORDER BY i.order_id, h.valid_from;

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
