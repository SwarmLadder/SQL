SELECT sku, product_name, unit_price_cents
FROM products
WHERE active = 1
ORDER BY unit_price_cents DESC, sku
LIMIT 3;
