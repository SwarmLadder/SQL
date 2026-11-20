-- Runs on a fresh, temporary in-memory database.
INSERT INTO products (product_id,sku,category_id,product_name,unit_price_cents,active)
VALUES (99,'DEMO99',2,'Practice Planner',1900,1);
SELECT sku,product_name,unit_price_cents FROM products WHERE product_id=99;
UPDATE products SET unit_price_cents=2100 WHERE product_id=99;
SELECT sku,unit_price_cents FROM products WHERE product_id=99;
DELETE FROM products WHERE product_id=99;
SELECT COUNT(*) AS remaining_demo_rows FROM products WHERE product_id=99;
