CREATE TABLE idempotency_keys (
  request_key TEXT PRIMARY KEY,
  request_hash TEXT NOT NULL,
  response_code INTEGER NOT NULL,
  created_at TEXT NOT NULL
);
INSERT OR IGNORE INTO idempotency_keys VALUES ('req-1', 'h1', 201, '2026-11-01');
INSERT OR IGNORE INTO idempotency_keys VALUES ('req-1', 'h1', 201, '2026-11-01');
