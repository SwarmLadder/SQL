-- 04 · UPSERT and idempotency keys
-- Examples from advanced/lessons/04_upsert_idempotency.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/lessons/04_upsert_idempotency.sql
CREATE TABLE newsletter (email TEXT PRIMARY KEY, subscribed_at TEXT NOT NULL);

INSERT INTO newsletter VALUES ('ana@example.test', '2026-01-05')
ON CONFLICT(email) DO NOTHING;
INSERT INTO newsletter VALUES ('ana@example.test', '2026-02-01')
ON CONFLICT(email) DO NOTHING;
SELECT changes() AS second_insert_changed;

SELECT * FROM newsletter;

CREATE TABLE product_stats (
  product_id INTEGER PRIMARY KEY,
  units_sold INTEGER NOT NULL,
  last_sold_at TEXT NOT NULL
);

INSERT INTO product_stats VALUES (1, 2, '2026-01-12')
ON CONFLICT(product_id) DO UPDATE
  SET units_sold = units_sold + excluded.units_sold,
      last_sold_at = max(last_sold_at, excluded.last_sold_at);

INSERT INTO product_stats VALUES (1, 3, '2026-05-04')
ON CONFLICT(product_id) DO UPDATE
  SET units_sold = units_sold + excluded.units_sold,
      last_sold_at = max(last_sold_at, excluded.last_sold_at);

SELECT * FROM product_stats;

CREATE TABLE profiles (customer_id INTEGER PRIMARY KEY, nickname TEXT, newsletter INTEGER NOT NULL DEFAULT 0);
INSERT INTO profiles VALUES (1, 'ana', 1);

INSERT OR REPLACE INTO profiles (customer_id, nickname) VALUES (1, 'ana_i');
SELECT * FROM profiles;

CREATE TABLE idempotency_keys (
  idem_key      TEXT PRIMARY KEY,
  request_hash  TEXT NOT NULL,
  response_code INTEGER NOT NULL,
  order_id      INTEGER NOT NULL REFERENCES orders(order_id),
  created_at    TEXT NOT NULL
);

-- First attempt: do the work and record the outcome atomically.
BEGIN;
INSERT INTO orders VALUES (500, 3, '2026-09-10', 'pending');
INSERT INTO idempotency_keys VALUES ('k-123', 'hash:qty=2', 201, 500, '2026-09-10');
COMMIT;

WITH incoming(idem_key, request_hash) AS (
  VALUES ('k-123', 'hash:qty=2'),   -- exact retry
         ('k-123', 'hash:qty=5'),   -- same key, different body: client bug
         ('k-999', 'hash:qty=1')    -- new request
)
SELECT i.idem_key, i.request_hash,
       CASE
         WHEN k.idem_key IS NULL               THEN 'new: do the work'
         WHEN k.request_hash = i.request_hash  THEN 'replay: return stored ' || k.response_code
         ELSE 'conflict: reject with 422'
       END AS decision
FROM incoming i
LEFT JOIN idempotency_keys k ON k.idem_key = i.idem_key;
