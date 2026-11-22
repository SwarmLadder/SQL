BEGIN;
SAVEPOINT before_mistake;
UPDATE products SET unit_price_cents = 0 WHERE product_id = 1;
ROLLBACK TO before_mistake;
RELEASE before_mistake;
UPDATE products SET unit_price_cents = 300 WHERE product_id = 2;
COMMIT;
