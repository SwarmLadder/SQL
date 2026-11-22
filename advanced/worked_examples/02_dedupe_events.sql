-- Worked example A2: removing duplicate events, then preventing new ones.
-- A retrying webhook delivered "order_paid" for order 101 three times.
BEGIN;
INSERT INTO audit_events VALUES
  (10, 'order_paid', '2026-01-12', '{"order_id":101}'),
  (11, 'order_paid', '2026-01-13', '{"order_id":101}');

-- Step 1: find duplicates. Same type + same payload = same business event.
SELECT event_type, json_extract(payload_json, '$.order_id') AS order_id, COUNT(*) AS copies
FROM audit_events
GROUP BY event_type, json_extract(payload_json, '$.order_id')
HAVING COUNT(*) > 1;

-- Step 2: keep the earliest copy, delete the rest. ROW_NUMBER picks exactly one survivor.
DELETE FROM audit_events
WHERE event_id IN (
  SELECT event_id FROM (
    SELECT event_id,
           ROW_NUMBER() OVER (PARTITION BY event_type, json_extract(payload_json, '$.order_id')
                              ORDER BY created_at, event_id) AS rn
    FROM audit_events
  ) WHERE rn > 1
);

-- Step 3: make the database refuse future duplicates (an expression index).
CREATE UNIQUE INDEX uq_audit_event ON audit_events(event_type, json_extract(payload_json, '$.order_id'));

-- Step 4: prove it. The retry is ignored instead of creating a fourth copy.
INSERT OR IGNORE INTO audit_events VALUES (12, 'order_paid', '2026-01-14', '{"order_id":101}');
SELECT event_id, event_type, created_at FROM audit_events
WHERE json_extract(payload_json, '$.order_id') = 101;
ROLLBACK;
