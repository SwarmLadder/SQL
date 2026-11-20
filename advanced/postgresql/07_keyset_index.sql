-- PostgreSQL only: composite cursor for a tenant feed.
BEGIN;
CREATE TEMP TABLE demo_feed (
  id BIGINT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  title TEXT NOT NULL
);
INSERT INTO demo_feed VALUES
(1,'tenant-a','2026-11-20 10:00:00+00','First'),
(2,'tenant-a','2026-11-20 11:00:00+00','Second'),
(3,'tenant-a','2026-11-20 11:00:00+00','Third'),
(4,'tenant-a','2026-11-20 12:00:00+00','Fourth'),
(5,'tenant-b','2026-11-20 11:00:00+00','Other tenant');
CREATE INDEX demo_feed_seek ON demo_feed(tenant_id,created_at DESC,id DESC);
EXPLAIN SELECT id,created_at FROM demo_feed
WHERE tenant_id='tenant-a'
  AND (created_at,id) < ('2026-11-20 11:00:00+00'::timestamptz,3)
ORDER BY created_at DESC,id DESC LIMIT 2;
SELECT id,created_at FROM demo_feed
WHERE tenant_id='tenant-a'
  AND (created_at,id) < ('2026-11-20 11:00:00+00'::timestamptz,3)
ORDER BY created_at DESC,id DESC LIMIT 2;
ROLLBACK;
