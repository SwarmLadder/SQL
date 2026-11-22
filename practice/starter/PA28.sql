-- PA28: Optimistic locking  (advanced, script)
-- Create documents(doc_id INTEGER PRIMARY KEY, body TEXT NOT NULL, version INTEGER NOT
-- NULL) with (1, 'draft', 1). Two clients both read version 1. Write client A's save (body
-- 'A') and then client B's save (body 'B'), each as an UPDATE that only succeeds if the
-- version is still the one they read, and bumps the version.
--
-- Write a SQL script. End every statement with a semicolon.
-- Check:  python tools/practice.py check PA28
-- Hints:  python tools/practice.py hint PA28 1

