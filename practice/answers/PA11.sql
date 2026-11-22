CREATE TABLE price_changes (product_id INTEGER, old_price_cents INTEGER, new_price_cents INTEGER);
CREATE TRIGGER log_price_change
AFTER UPDATE OF unit_price_cents ON products
WHEN OLD.unit_price_cents <> NEW.unit_price_cents
BEGIN
  INSERT INTO price_changes VALUES (NEW.product_id, OLD.unit_price_cents, NEW.unit_price_cents);
END;
