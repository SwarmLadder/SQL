SELECT product_name, unit_price_cents
FROM products ORDER BY unit_price_cents DESC, product_name ASC;
SELECT full_name, city FROM customers ORDER BY city, full_name LIMIT 5;
SELECT order_id, ordered_at FROM orders ORDER BY ordered_at DESC, order_id DESC LIMIT 3;
SELECT product_name FROM products ORDER BY product_name LIMIT 4 OFFSET 2;
