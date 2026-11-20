SAVEPOINT transfer_demo;
UPDATE products SET unit_price_cents=unit_price_cents+500 WHERE product_id=1;
UPDATE products SET unit_price_cents=unit_price_cents-100 WHERE product_id=2;
SELECT product_id,unit_price_cents FROM products WHERE product_id IN (1,2);
ROLLBACK TO transfer_demo;
RELEASE transfer_demo;
SELECT product_id,unit_price_cents FROM products WHERE product_id IN (1,2);
-- Show the current foreign-key enforcement setting.
PRAGMA foreign_keys;
