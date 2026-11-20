-- Expand: add a field compatible with old writers.
ALTER TABLE customers ADD COLUMN account_tier TEXT NOT NULL DEFAULT 'basic';
-- Backfill a subset after deployment.
UPDATE customers SET account_tier='premium' WHERE customer_id=1;
-- Contract/removal is deliberately not done during a mixed-version rollout.
SELECT customer_id,account_tier FROM customers ORDER BY customer_id;
