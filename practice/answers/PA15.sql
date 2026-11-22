ALTER TABLE customers ADD COLUMN marketing_opt_in INTEGER NOT NULL DEFAULT 0
  CHECK (marketing_opt_in IN (0, 1));
UPDATE customers SET marketing_opt_in = 1
WHERE EXISTS (
  SELECT 1 FROM orders o WHERE o.customer_id = customers.customer_id AND o.status = 'paid'
);
