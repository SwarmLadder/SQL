CREATE TABLE wallets (
  customer_id INTEGER PRIMARY KEY,
  balance_cents INTEGER NOT NULL CHECK (balance_cents >= 0)
);
INSERT INTO wallets VALUES (1, 1000), (2, 200);
UPDATE wallets SET balance_cents = balance_cents - 300 WHERE customer_id = 1 AND balance_cents >= 300;
UPDATE wallets SET balance_cents = balance_cents - 300 WHERE customer_id = 2 AND balance_cents >= 300;
