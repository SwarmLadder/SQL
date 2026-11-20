-- Both inbox and outbox belong in the business transaction.
CREATE TABLE demo_inbox(
 tenant_id TEXT NOT NULL,event_key TEXT NOT NULL,payload_hash TEXT NOT NULL,
 result TEXT NOT NULL,PRIMARY KEY(tenant_id,event_key)
);
CREATE TABLE demo_outbox(
 tenant_id TEXT NOT NULL,event_key TEXT NOT NULL,message TEXT NOT NULL,
 PRIMARY KEY(tenant_id,event_key)
);
SAVEPOINT process_request;
INSERT INTO demo_inbox VALUES ('tenant-a','evt-1','hash-1','accepted');
INSERT INTO demo_outbox VALUES ('tenant-a','evt-1','order created');
RELEASE process_request;
-- Duplicate id is retained, but real handlers must compare payloads.
INSERT INTO demo_inbox VALUES ('tenant-a','evt-1','hash-1','accepted')
ON CONFLICT(tenant_id,event_key) DO NOTHING;
SELECT * FROM demo_inbox;
SELECT * FROM demo_outbox;
