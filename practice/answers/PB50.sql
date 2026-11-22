UPDATE products
SET unit_price_cents = unit_price_cents * 110 / 100
WHERE category_id = 2 AND active = 1;
