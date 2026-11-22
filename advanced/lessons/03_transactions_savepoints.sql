-- 03 · Atomic changes and savepoints
-- Examples from advanced/lessons/03_transactions_savepoints.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/lessons/03_transactions_savepoints.sql
CREATE TABLE wallets (
  customer_id INTEGER PRIMARY KEY REFERENCES customers(customer_id),
  balance_cents INTEGER NOT NULL CHECK (balance_cents >= 0)
);
INSERT INTO wallets VALUES (1, 1000), (2, 200);

BEGIN;
UPDATE wallets SET balance_cents = balance_cents - 500 WHERE customer_id = 1;
UPDATE wallets SET balance_cents = balance_cents + 500 WHERE customer_id = 2;
COMMIT;

SELECT customer_id, balance_cents, SUM(balance_cents) OVER () AS total FROM wallets;

UPDATE wallets
SET balance_cents = balance_cents - 100
WHERE customer_id = 2 AND balance_cents >= 100;

SELECT changes() AS rows_changed, balance_cents FROM wallets WHERE customer_id = 2;

ALTER TABLE wallets ADD COLUMN version INTEGER NOT NULL DEFAULT 1;

-- The client read version 1. Its update only succeeds if nobody changed the row since.
UPDATE wallets SET balance_cents = 999, version = version + 1
WHERE customer_id = 1 AND version = 1;
SELECT changes() AS first_writer;

-- A second client, also holding version 1, now fails cleanly instead of overwriting.
UPDATE wallets SET balance_cents = 111, version = version + 1
WHERE customer_id = 1 AND version = 1;
SELECT changes() AS second_writer;

BEGIN;
UPDATE products SET unit_price_cents = 1300 WHERE product_id = 1;   -- keep
SAVEPOINT outer_step;
UPDATE products SET unit_price_cents = 300 WHERE product_id = 2;    -- keep
SAVEPOINT inner_step;
UPDATE products SET unit_price_cents = 1 WHERE product_id = 6;      -- undo
ROLLBACK TO inner_step;
RELEASE outer_step;
COMMIT;

SELECT product_id, unit_price_cents FROM products WHERE product_id IN (1, 2, 6) ORDER BY product_id;
