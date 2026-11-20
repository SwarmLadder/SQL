-- Select specific columns.
SELECT customer_id, full_name, city FROM customers;
-- Rename output fields for reports.
SELECT product_name AS item, unit_price_cents AS price_cents FROM products;
-- Return a constant and calculated field.
SELECT sku, unit_price_cents / 100.0 AS price_display FROM products;
-- Distinct removes duplicate projected rows.
SELECT DISTINCT city FROM customers;
