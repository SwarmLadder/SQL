-- PostgreSQL only. Measure on the target server and realistic data.
BEGIN;
CREATE TEMP TABLE demo_measurements (id INTEGER PRIMARY KEY, category INTEGER NOT NULL);
INSERT INTO demo_measurements
SELECT n, (n % 20) FROM generate_series(1,10000) AS n;
CREATE INDEX demo_measurements_category ON demo_measurements(category);
ANALYZE demo_measurements;
EXPLAIN (ANALYZE, BUFFERS) SELECT COUNT(*) FROM demo_measurements WHERE category=7;
ROLLBACK;
