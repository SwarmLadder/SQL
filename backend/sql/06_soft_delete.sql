-- Partial unique index: one active email per tenant, old records retained.
CREATE TABLE demo_members(
 member_id INTEGER PRIMARY KEY,
 tenant_id TEXT NOT NULL,
 email TEXT NOT NULL,
 deleted_at TEXT
);
CREATE UNIQUE INDEX uq_active_tenant_email ON demo_members(tenant_id,email)
WHERE deleted_at IS NULL;
INSERT INTO demo_members VALUES (1,'tenant-a','same@example.test',NULL);
UPDATE demo_members SET deleted_at='2026-11-20' WHERE member_id=1;
INSERT INTO demo_members VALUES (2,'tenant-a','same@example.test',NULL);
SELECT member_id,email FROM demo_members WHERE tenant_id='tenant-a'
AND deleted_at IS NULL ORDER BY member_id;
