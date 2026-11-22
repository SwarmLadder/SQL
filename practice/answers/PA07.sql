BEGIN;
SAVEPOINT price_test;
UPDATE products SET unit_price_cents = 14900 WHERE product_id = 4;
UPDATE products SET unit_price_cents = 5900 WHERE product_id = 8;
ROLLBACK TO price_test;
RELEASE price_test;
UPDATE products SET active = 0 WHERE product_id = 2;
COMMIT;
