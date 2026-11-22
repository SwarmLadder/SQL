CREATE TABLE documents (doc_id INTEGER PRIMARY KEY, body TEXT NOT NULL, version INTEGER NOT NULL);
INSERT INTO documents VALUES (1, 'draft', 1);
UPDATE documents SET body = 'A', version = version + 1 WHERE doc_id = 1 AND version = 1;
UPDATE documents SET body = 'B', version = version + 1 WHERE doc_id = 1 AND version = 1;
