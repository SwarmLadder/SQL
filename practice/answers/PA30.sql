CREATE TABLE last_seen (product_id INTEGER PRIMARY KEY, seen_at TEXT NOT NULL);
INSERT INTO last_seen VALUES (1, '2026-05-01') ON CONFLICT(product_id) DO UPDATE SET seen_at = max(seen_at, excluded.seen_at);
INSERT INTO last_seen VALUES (1, '2026-03-01') ON CONFLICT(product_id) DO UPDATE SET seen_at = max(seen_at, excluded.seen_at);
INSERT INTO last_seen VALUES (2, '2026-04-01') ON CONFLICT(product_id) DO UPDATE SET seen_at = max(seen_at, excluded.seen_at);
