-- Worked example B6 · Pagination that doesn't skip rows
-- Examples from basics/worked_examples/06_stable_pagination.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py basics/worked_examples/06_stable_pagination.sql
INSERT INTO products (product_id, sku, category_id, product_name, unit_price_cents) VALUES
  (20, 'P20', 2, 'Eraser', 450),
  (21, 'P21', 2, 'Ruler',  450);

SELECT sku, unit_price_cents FROM products
WHERE active = 1
ORDER BY unit_price_cents
LIMIT 3 OFFSET 0;

SELECT sku, unit_price_cents FROM products
WHERE active = 1
ORDER BY unit_price_cents
LIMIT 3 OFFSET 3;

SELECT sku, unit_price_cents FROM products
WHERE active = 1
ORDER BY unit_price_cents, sku
LIMIT 3 OFFSET 0;

SELECT sku, unit_price_cents FROM products
WHERE active = 1
ORDER BY unit_price_cents, sku
LIMIT 3 OFFSET 3;

SELECT COUNT(*) AS listed, COUNT(DISTINCT sku) AS distinct_listed
FROM (SELECT sku FROM (SELECT sku FROM products WHERE active = 1 ORDER BY unit_price_cents, sku LIMIT 3 OFFSET 0)
      UNION ALL
      SELECT sku FROM (SELECT sku FROM products WHERE active = 1 ORDER BY unit_price_cents, sku LIMIT 3 OFFSET 3)
      UNION ALL
      SELECT sku FROM (SELECT sku FROM products WHERE active = 1 ORDER BY unit_price_cents, sku LIMIT 3 OFFSET 6)
      UNION ALL
      SELECT sku FROM (SELECT sku FROM products WHERE active = 1 ORDER BY unit_price_cents, sku LIMIT 3 OFFSET 9));
