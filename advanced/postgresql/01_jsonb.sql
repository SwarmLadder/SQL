-- PostgreSQL only. JSONB indexing and extraction.
BEGIN;
CREATE TEMP TABLE demo_catalog (id INTEGER PRIMARY KEY, details JSONB NOT NULL);
INSERT INTO demo_catalog VALUES
(1,'{"category":"books","tags":["sql","learning"]}'),
(2,'{"category":"stationery","tags":["pen"]}');
SELECT id, details->>'category' AS category FROM demo_catalog ORDER BY id;
SELECT id FROM demo_catalog WHERE details @> '{"category":"books"}';
CREATE INDEX demo_catalog_gin ON demo_catalog USING GIN(details);
EXPLAIN SELECT id FROM demo_catalog WHERE details @> '{"category":"books"}';
ROLLBACK;
