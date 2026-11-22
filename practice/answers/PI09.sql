SELECT sku,
  CASE
    WHEN unit_price_cents < 1000 THEN 'budget'
    WHEN unit_price_cents < 10000 THEN 'standard'
    ELSE 'premium'
  END AS price_band
FROM products
ORDER BY sku;
