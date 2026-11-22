SELECT sku, unit_price_cents
FROM products
WHERE active = 1 AND unit_price_cents BETWEEN 1000 AND 6000
ORDER BY unit_price_cents, sku;
