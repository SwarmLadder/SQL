CREATE TABLE addresses (
  address_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  is_default INTEGER NOT NULL DEFAULT 0 CHECK (is_default IN (0, 1))
);
CREATE UNIQUE INDEX one_default_address ON addresses(customer_id) WHERE is_default = 1;
