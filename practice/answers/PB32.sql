SELECT sku, unit_price_cents * 90 / 100 AS discounted_cents
FROM products
ORDER BY sku;
