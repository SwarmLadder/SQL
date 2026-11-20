-- SQLite schema: integer cents avoid floating-point currency arithmetic.
PRAGMA foreign_keys = ON;

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  city TEXT NOT NULL,
  joined_at TEXT NOT NULL
);
CREATE TABLE categories (
  category_id INTEGER PRIMARY KEY,
  category_name TEXT NOT NULL UNIQUE
);
CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  sku TEXT NOT NULL UNIQUE,
  category_id INTEGER NOT NULL REFERENCES categories(category_id),
  product_name TEXT NOT NULL,
  unit_price_cents INTEGER NOT NULL CHECK (unit_price_cents >= 0),
  active INTEGER NOT NULL DEFAULT 1 CHECK(active IN (0, 1))
);
CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
  ordered_at TEXT NOT NULL,
  status TEXT NOT NULL CHECK(status IN ('pending', 'paid', 'cancelled'))
);
CREATE TABLE order_items (
  order_id INTEGER NOT NULL REFERENCES orders(order_id),
  product_id INTEGER NOT NULL REFERENCES products(product_id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price_cents INTEGER NOT NULL CHECK (unit_price_cents >= 0),
  PRIMARY KEY (order_id, product_id)
);
CREATE TABLE payments (
  payment_id INTEGER PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(order_id),
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  method TEXT NOT NULL CHECK(method IN ('card', 'cash', 'transfer')),
  paid_at TEXT NOT NULL
);
CREATE TABLE teams (
  team_id INTEGER PRIMARY KEY,
  team_name TEXT NOT NULL UNIQUE
);
CREATE TABLE employees (
  employee_id INTEGER PRIMARY KEY,
  full_name TEXT NOT NULL,
  team_id INTEGER NOT NULL REFERENCES teams(team_id),
  salary_cents INTEGER NOT NULL CHECK(salary_cents >= 0),
  manager_id INTEGER REFERENCES employees(employee_id)
);
CREATE TABLE audit_events (
  event_id INTEGER PRIMARY KEY,
  event_type TEXT NOT NULL,
  created_at TEXT NOT NULL,
  payload_json TEXT NOT NULL
);
CREATE INDEX idx_orders_customer_date ON orders(customer_id, ordered_at);
CREATE INDEX idx_items_product ON order_items(product_id);
CREATE INDEX idx_employees_manager ON employees(manager_id);
