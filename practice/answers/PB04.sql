SELECT sku, unit_price_cents
FROM products
WHERE unit_price_cents < 500
ORDER BY unit_price_cents, sku;
