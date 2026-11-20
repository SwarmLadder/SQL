-- PostgreSQL only: optimistic-lock update with expected version.
BEGIN;
CREATE TEMP TABLE demo_prices (
  product_id INTEGER PRIMARY KEY,
  amount_cents INTEGER NOT NULL CHECK(amount_cents>=0),
  version INTEGER NOT NULL DEFAULT 1
);
INSERT INTO demo_prices(product_id,amount_cents) VALUES (1,1000);
UPDATE demo_prices SET amount_cents=1200,version=version+1
WHERE product_id=1 AND version=1
RETURNING product_id,amount_cents,version;
-- Stale writer attempts version=1: returns zero rows, no overwrite.
UPDATE demo_prices SET amount_cents=500,version=version+1
WHERE product_id=1 AND version=1
RETURNING product_id,amount_cents,version;
SELECT * FROM demo_prices;
ROLLBACK;
