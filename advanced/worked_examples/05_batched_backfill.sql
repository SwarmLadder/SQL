-- Worked example A5 · A backfill in batches
-- Examples from advanced/worked_examples/05_batched_backfill.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/worked_examples/05_batched_backfill.sql
ALTER TABLE customers ADD COLUMN lifetime_cents INTEGER;

UPDATE customers
SET lifetime_cents = COALESCE((SELECT SUM(i.quantity * i.unit_price_cents)
                               FROM orders o JOIN order_items i ON i.order_id = o.order_id
                               WHERE o.customer_id = customers.customer_id AND o.status = 'paid'), 0)
WHERE customer_id IN (SELECT customer_id FROM customers
                      WHERE lifetime_cents IS NULL ORDER BY customer_id LIMIT 3);
SELECT COUNT(*) AS remaining FROM customers WHERE lifetime_cents IS NULL;

UPDATE customers
SET lifetime_cents = COALESCE((SELECT SUM(i.quantity * i.unit_price_cents)
                               FROM orders o JOIN order_items i ON i.order_id = o.order_id
                               WHERE o.customer_id = customers.customer_id AND o.status = 'paid'), 0)
WHERE customer_id IN (SELECT customer_id FROM customers
                      WHERE lifetime_cents IS NULL ORDER BY customer_id LIMIT 3);
UPDATE customers
SET lifetime_cents = COALESCE((SELECT SUM(i.quantity * i.unit_price_cents)
                               FROM orders o JOIN order_items i ON i.order_id = o.order_id
                               WHERE o.customer_id = customers.customer_id AND o.status = 'paid'), 0)
WHERE customer_id IN (SELECT customer_id FROM customers
                      WHERE lifetime_cents IS NULL ORDER BY customer_id LIMIT 3);
SELECT COUNT(*) AS remaining FROM customers WHERE lifetime_cents IS NULL;

SELECT COUNT(*) AS wrong_rows
FROM customers c
WHERE c.lifetime_cents IS NOT COALESCE((SELECT SUM(i.quantity * i.unit_price_cents)
                                        FROM orders o JOIN order_items i ON i.order_id = o.order_id
                                        WHERE o.customer_id = c.customer_id AND o.status = 'paid'), 0);
SELECT SUM(lifetime_cents) AS backfilled_total FROM customers;
