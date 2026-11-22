CREATE TABLE archived_orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  ordered_at TEXT NOT NULL
);
INSERT INTO archived_orders (order_id, customer_id, ordered_at)
SELECT order_id, customer_id, ordered_at FROM orders WHERE status = 'cancelled';
