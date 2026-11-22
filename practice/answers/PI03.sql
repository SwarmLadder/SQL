SELECT sku, unit_price_cents
FROM products
WHERE unit_price_cents > (SELECT AVG(unit_price_cents) FROM products)
ORDER BY unit_price_cents DESC, sku;
