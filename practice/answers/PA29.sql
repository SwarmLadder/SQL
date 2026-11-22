CREATE TABLE subscribers (email TEXT PRIMARY KEY, first_seen TEXT NOT NULL);
INSERT INTO subscribers VALUES ('ana@example.test', '2026-01-05') ON CONFLICT(email) DO NOTHING;
INSERT INTO subscribers VALUES ('bo@example.test', '2026-01-06') ON CONFLICT(email) DO NOTHING;
INSERT INTO subscribers VALUES ('ana@example.test', '2026-02-01') ON CONFLICT(email) DO NOTHING;
