CREATE TRIGGER keep_paid_orders
BEFORE DELETE ON orders
WHEN OLD.status = 'paid'
BEGIN
  SELECT RAISE(ABORT, 'paid orders cannot be deleted');
END;
