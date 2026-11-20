-- PostgreSQL only: business state and outbox event in one transaction.
BEGIN;
CREATE TEMP TABLE demo_orders (
  order_id BIGINT PRIMARY KEY,
  status TEXT NOT NULL CHECK(status IN ('new','paid'))
);
CREATE TEMP TABLE demo_outbox (
  event_id TEXT PRIMARY KEY,
  order_id BIGINT NOT NULL REFERENCES demo_orders(order_id),
  message TEXT NOT NULL
);
INSERT INTO demo_orders VALUES (101,'new');
INSERT INTO demo_outbox VALUES ('evt-101',101,'ORDER_CREATED');
SELECT o.order_id,o.status,x.event_id,x.message
FROM demo_orders o JOIN demo_outbox x ON x.order_id=o.order_id;
-- Publishing must be a separate retryable worker with deduplication.
ROLLBACK;
