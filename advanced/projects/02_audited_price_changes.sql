CREATE TABLE product_price_changes (
  change_id INTEGER PRIMARY KEY,
  product_id INTEGER NOT NULL,
  previous_cents INTEGER NOT NULL,
  current_cents INTEGER NOT NULL
);
CREATE TRIGGER audit_price AFTER UPDATE OF unit_price_cents ON products
WHEN OLD.unit_price_cents <> NEW.unit_price_cents
BEGIN
 INSERT INTO product_price_changes(product_id,previous_cents,current_cents)
 VALUES(OLD.product_id,OLD.unit_price_cents,NEW.unit_price_cents);
END;
SAVEPOINT demo_change;
UPDATE products SET unit_price_cents=1350 WHERE product_id=1;
SELECT * FROM product_price_changes ORDER BY change_id;
ROLLBACK TO demo_change;
RELEASE demo_change;
SELECT unit_price_cents FROM products WHERE product_id=1;
SELECT COUNT(*) AS retained_changes FROM product_price_changes;
-- Committed demonstration change (in-memory only).
UPDATE products SET unit_price_cents=1300 WHERE product_id=1;
SELECT * FROM product_price_changes ORDER BY change_id;
