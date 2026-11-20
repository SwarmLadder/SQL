CREATE TABLE price_audit (
  audit_id INTEGER PRIMARY KEY,
  product_id INTEGER NOT NULL,
  old_price_cents INTEGER NOT NULL,
  new_price_cents INTEGER NOT NULL
);
CREATE TRIGGER log_product_price AFTER UPDATE OF unit_price_cents ON products
WHEN OLD.unit_price_cents <> NEW.unit_price_cents
BEGIN
  INSERT INTO price_audit(product_id,old_price_cents,new_price_cents)
  VALUES(OLD.product_id,OLD.unit_price_cents,NEW.unit_price_cents);
END;
UPDATE products SET unit_price_cents=1300 WHERE product_id=1;
UPDATE products SET product_name=product_name WHERE product_id=2;
SELECT * FROM price_audit ORDER BY audit_id;
