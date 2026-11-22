-- Idempotent Payment Intake: reference solution. Runs on a fresh sample database.

-- Ticket 1: schema for webhook deliveries, keyed by the provider's event id.
CREATE TABLE payment_events (
  event_id     TEXT PRIMARY KEY,
  order_id     INTEGER NOT NULL REFERENCES orders(order_id),
  amount_cents INTEGER NOT NULL CHECK (amount_cents > 0),
  payload_hash TEXT NOT NULL,
  received_at  TEXT NOT NULL
);
CREATE INDEX idx_payment_events_order ON payment_events(order_id);

-- Ticket 2: rule "a payment can't exceed what is still owed", enforced in the database.
CREATE TRIGGER no_overpayment
BEFORE INSERT ON payments
WHEN NEW.amount_cents + COALESCE((SELECT SUM(amount_cents) FROM payments WHERE order_id = NEW.order_id), 0)
     > (SELECT SUM(quantity * unit_price_cents) FROM order_items WHERE order_id = NEW.order_id)
BEGIN
  SELECT RAISE(ABORT, 'payment exceeds the order total');
END;

-- Ticket 3: intake of one delivery, atomically. Pending order 104 (5500 cents) is paid.
BEGIN;
INSERT INTO payment_events VALUES ('evt_1', 104, 5500, 'h-104-5500', '2026-03-13T10:00');
INSERT INTO payments VALUES (20, 104, 5500, 'card', '2026-03-13');
UPDATE orders SET status = 'paid' WHERE order_id = 104 AND status = 'pending';
COMMIT;

-- The provider retries the same delivery: the event key makes it a no-op.
INSERT INTO payment_events VALUES ('evt_1', 104, 5500, 'h-104-5500', '2026-03-13T10:05')
ON CONFLICT(event_id) DO NOTHING;
SELECT changes() AS retry_inserted;

-- Ticket 4: classify incoming deliveries before acting on them.
WITH incoming(event_id, payload_hash) AS (
  VALUES ('evt_1', 'h-104-5500'), ('evt_1', 'h-104-9999'), ('evt_2', 'h-108-2500')
)
SELECT i.event_id,
       CASE
         WHEN e.event_id IS NULL                  THEN 'process'
         WHEN e.payload_hash = i.payload_hash     THEN 'duplicate: acknowledge'
         ELSE 'conflict: alert'
       END AS action
FROM incoming i
LEFT JOIN payment_events e ON e.event_id = i.event_id
ORDER BY i.event_id, i.payload_hash;

-- Ticket 5: reconciliation after intake: every paid order has exactly its total.
WITH items AS (SELECT order_id, SUM(quantity * unit_price_cents) AS item_cents FROM order_items GROUP BY order_id),
     paid  AS (SELECT order_id, SUM(amount_cents) AS paid_cents FROM payments GROUP BY order_id)
SELECT o.order_id, o.status, i.item_cents, COALESCE(p.paid_cents, 0) AS paid_cents
FROM orders o
JOIN items i ON i.order_id = o.order_id
LEFT JOIN paid p ON p.order_id = o.order_id
WHERE (o.status = 'paid') <> (COALESCE(p.paid_cents, 0) = i.item_cents)
ORDER BY o.order_id;

-- Ticket 6: the lookup the webhook handler runs on every delivery uses the primary key.
EXPLAIN QUERY PLAN SELECT payload_hash FROM payment_events WHERE event_id = 'evt_1';
