-- 05 · Triggers and audit history
-- Examples from advanced/lessons/05_triggers_audit.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/lessons/05_triggers_audit.sql
CREATE TABLE price_audit (
  audit_id INTEGER PRIMARY KEY,
  product_id INTEGER NOT NULL,
  old_price_cents INTEGER NOT NULL,
  new_price_cents INTEGER NOT NULL,
  changed_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TRIGGER audit_price_change
AFTER UPDATE OF unit_price_cents ON products
WHEN OLD.unit_price_cents <> NEW.unit_price_cents
BEGIN
  INSERT INTO price_audit (product_id, old_price_cents, new_price_cents)
  VALUES (NEW.product_id, OLD.unit_price_cents, NEW.unit_price_cents);
END;

UPDATE products SET unit_price_cents = 1300 WHERE product_id = 1;   -- logged
UPDATE products SET unit_price_cents = 250  WHERE product_id = 2;   -- same value: not logged
UPDATE products SET active = 0 WHERE product_id = 3;                -- other column: not fired

SELECT product_id, old_price_cents, new_price_cents FROM price_audit;

CREATE TRIGGER limit_price_jump
BEFORE UPDATE OF unit_price_cents ON products
WHEN NEW.unit_price_cents > OLD.unit_price_cents * 3 / 2
BEGIN
  SELECT RAISE(ABORT, 'price increase above 50% needs approval');
END;

CREATE TABLE order_line_counts (order_id INTEGER PRIMARY KEY, line_count INTEGER NOT NULL);
INSERT INTO order_line_counts SELECT order_id, COUNT(*) FROM order_items GROUP BY order_id;

CREATE TRIGGER count_line_insert AFTER INSERT ON order_items
BEGIN
  INSERT INTO order_line_counts VALUES (NEW.order_id, 1)
  ON CONFLICT(order_id) DO UPDATE SET line_count = line_count + 1;
END;

CREATE TRIGGER count_line_delete AFTER DELETE ON order_items
BEGIN
  UPDATE order_line_counts SET line_count = line_count - 1 WHERE order_id = OLD.order_id;
END;

INSERT INTO order_items VALUES (101, 3, 1, 4900);
DELETE FROM order_items WHERE order_id = 104;
SELECT order_id, line_count FROM order_line_counts WHERE order_id IN (101, 104);
