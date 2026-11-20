CREATE TABLE coupon_codes (
  coupon_id INTEGER PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,
  discount_percent INTEGER NOT NULL CHECK(discount_percent BETWEEN 1 AND 100),
  active INTEGER NOT NULL DEFAULT 1 CHECK(active IN (0,1))
);
INSERT INTO coupon_codes(code,discount_percent) VALUES ('WELCOME',10);
ALTER TABLE coupon_codes ADD COLUMN created_at TEXT NOT NULL DEFAULT '2026-11-20';
SELECT * FROM coupon_codes;
PRAGMA table_info(coupon_codes);
PRAGMA foreign_key_check;
