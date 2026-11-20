-- PostgreSQL only. Multi-session behavior is not demonstrated in one session.
BEGIN;
CREATE TEMP TABLE demo_jobs (job_id INTEGER PRIMARY KEY, status TEXT NOT NULL);
INSERT INTO demo_jobs VALUES (1,'queued'),(2,'queued'),(3,'done');
SELECT job_id FROM demo_jobs
WHERE status='queued'
ORDER BY job_id
FOR UPDATE SKIP LOCKED LIMIT 1;
-- In real work queues: atomically claim a job, handle retries, leases, and crashes.
ROLLBACK;
