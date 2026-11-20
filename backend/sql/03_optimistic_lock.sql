-- Expand schema, then version-check each write.
ALTER TABLE products ADD COLUMN version INTEGER NOT NULL DEFAULT 1;
SELECT product_id,unit_price_cents,version FROM products WHERE product_id=1;
UPDATE products SET unit_price_cents=1400,version=version+1
WHERE product_id=1 AND version=1;
SELECT changes() AS updated_rows;
-- A stale update must not overwrite version 2.
UPDATE products SET unit_price_cents=900,version=version+1
WHERE product_id=1 AND version=1;
SELECT changes() AS stale_update_rows;
SELECT unit_price_cents,version FROM products WHERE product_id=1;
