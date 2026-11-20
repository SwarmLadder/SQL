-- PostgreSQL only. Isolation is session/transaction-specific.
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT current_setting('transaction_isolation') AS isolation;
SELECT txid_current() AS transaction_id;
ROLLBACK;
-- Compare concurrent sessions to observe anomalies; this single session cannot show them.
