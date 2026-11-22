-- 07 · Constraints and schema changes
-- Examples from advanced/lessons/07_constraints_migrations.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/lessons/07_constraints_migrations.sql
CREATE TABLE coupons (
  coupon_id   INTEGER PRIMARY KEY,
  code        TEXT    NOT NULL UNIQUE,
  percent_off INTEGER NOT NULL CHECK (percent_off BETWEEN 1 AND 90),
  starts_at   TEXT    NOT NULL,
  ends_at     TEXT    NOT NULL,
  CHECK (ends_at > starts_at)
);

INSERT INTO coupons (code, percent_off, starts_at, ends_at)
VALUES ('WELCOME10', 10, '2026-01-01', '2026-12-31');
SELECT coupon_id, code, percent_off FROM coupons;

CREATE TABLE reviews (
  customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
  product_id  INTEGER NOT NULL REFERENCES products(product_id),
  stars       INTEGER NOT NULL CHECK (stars BETWEEN 1 AND 5),
  UNIQUE (customer_id, product_id)
);
INSERT INTO reviews VALUES (1, 3, 5), (2, 3, 4);
SELECT COUNT(*) AS reviews FROM reviews;

CREATE TABLE addresses (
  address_id  INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  is_default  INTEGER NOT NULL DEFAULT 0 CHECK (is_default IN (0, 1))
);
CREATE UNIQUE INDEX one_default_address ON addresses(customer_id) WHERE is_default = 1;

INSERT INTO addresses (customer_id, is_default) VALUES (1, 1), (1, 0), (1, 0);
SELECT customer_id, SUM(is_default) AS defaults, COUNT(*) AS addresses FROM addresses GROUP BY customer_id;

CREATE TABLE carts (cart_id INTEGER PRIMARY KEY);
CREATE TABLE cart_lines (
  cart_id INTEGER NOT NULL REFERENCES carts(cart_id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL,
  PRIMARY KEY (cart_id, product_id)
);
INSERT INTO carts VALUES (1);
INSERT INTO cart_lines VALUES (1, 2), (1, 3);
DELETE FROM carts WHERE cart_id = 1;
SELECT COUNT(*) AS cart_lines_left FROM cart_lines;

ALTER TABLE customers ADD COLUMN loyalty_tier TEXT NOT NULL DEFAULT 'standard'
  CHECK (loyalty_tier IN ('standard', 'silver', 'gold'));

-- Old-style insert, unaware of the new column: still works.
INSERT INTO customers (customer_id, full_name, email, city, joined_at)
VALUES (30, 'Old Client Code', 'old@example.test', 'Arad', '2026-09-01');

-- Backfill in a separate step.
UPDATE customers SET loyalty_tier = 'gold'
WHERE customer_id IN (SELECT o.customer_id FROM orders o JOIN order_items i ON i.order_id = o.order_id
                      WHERE o.status = 'paid' GROUP BY o.customer_id
                      HAVING SUM(i.quantity * i.unit_price_cents) >= 20000);

SELECT loyalty_tier, COUNT(*) AS customers FROM customers GROUP BY loyalty_tier ORDER BY loyalty_tier;
