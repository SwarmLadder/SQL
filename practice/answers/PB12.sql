SELECT MIN(unit_price_cents) AS min_price, MAX(unit_price_cents) AS max_price
FROM products
WHERE active = 1;
