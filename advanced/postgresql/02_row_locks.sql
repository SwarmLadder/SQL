-- PostgreSQL only. Use a second session to observe contention.
BEGIN;
CREATE TEMP TABLE demo_accounts (id INTEGER PRIMARY KEY, balance INTEGER NOT NULL CHECK(balance>=0));
INSERT INTO demo_accounts VALUES (1,100), (2,20);
SELECT * FROM demo_accounts WHERE id=1 FOR UPDATE;
UPDATE demo_accounts SET balance=balance-10 WHERE id=1;
UPDATE demo_accounts SET balance=balance+10 WHERE id=2;
SELECT * FROM demo_accounts ORDER BY id;
ROLLBACK;
