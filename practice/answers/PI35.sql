WITH ranked AS (
  SELECT category_id, sku, unit_price_cents,
    ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY unit_price_cents DESC, sku) AS rn
  FROM products
)
SELECT category_id, sku, unit_price_cents
FROM ranked
WHERE rn = 1
ORDER BY category_id;
