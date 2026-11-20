SELECT sku, unit_price_cents, unit_price_cents / 100.0 AS price
FROM products ORDER BY sku;
SELECT full_name || ' (' || city || ')' AS customer_label FROM customers;
SELECT product_name, LENGTH(product_name) AS name_length
FROM products ORDER BY name_length DESC;
SELECT sku, ROUND(unit_price_cents * 1.19) AS price_with_tax_cents
FROM products;
