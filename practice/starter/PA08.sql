-- PA08: Idempotency keys  (advanced, script)
-- Create a table idempotency_keys(request_key TEXT, request_hash TEXT NOT NULL,
-- response_code INTEGER NOT NULL, created_at TEXT NOT NULL) where request_key is unique.
-- Then store ('req-1', 'h1', 201, '2026-11-01') twice so that the second attempt is
-- silently ignored. The checker then tries to insert a duplicate key and a new key.
--
-- Write a SQL script. End every statement with a semicolon.
-- Check:  python tools/practice.py check PA08
-- Hints:  python tools/practice.py hint PA08 1

