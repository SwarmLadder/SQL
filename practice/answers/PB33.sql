SELECT sku, printf('%.2f', unit_price_cents / 100.0) AS price_eur
FROM products
WHERE active = 1
ORDER BY sku;
