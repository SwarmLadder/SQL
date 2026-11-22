CREATE TABLE status_log (order_id INTEGER, old_status TEXT, new_status TEXT);
CREATE TRIGGER log_status_change
AFTER UPDATE OF status ON orders
WHEN OLD.status <> NEW.status
BEGIN
  INSERT INTO status_log VALUES (NEW.order_id, OLD.status, NEW.status);
END;
