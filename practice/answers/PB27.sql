SELECT sku, unit_price_cents
FROM products
WHERE active = 1
ORDER BY unit_price_cents, sku
LIMIT 2;
