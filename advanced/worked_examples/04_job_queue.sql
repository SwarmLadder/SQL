-- Worked example A4 · A job queue that never runs a job twice
-- Examples from advanced/worked_examples/04_job_queue.md, in order, on a fresh sample database.
-- Run: python tools/run_sql.py advanced/worked_examples/04_job_queue.sql
CREATE TABLE jobs (
  job_id     INTEGER PRIMARY KEY,
  order_id   INTEGER NOT NULL,
  status     TEXT NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'running', 'done')),
  worker     TEXT,
  lease_until TEXT
);
CREATE INDEX idx_jobs_ready ON jobs(status, job_id);
INSERT INTO jobs (order_id) SELECT order_id FROM orders WHERE status = 'paid';

UPDATE jobs
SET status = 'running', worker = 'A', lease_until = '2026-08-01T10:05'
WHERE job_id = (SELECT job_id FROM jobs WHERE status = 'queued' ORDER BY job_id LIMIT 1)
  AND status = 'queued'
RETURNING job_id, order_id, worker;

UPDATE jobs
SET status = 'running', worker = 'B', lease_until = '2026-08-01T10:05'
WHERE job_id = (SELECT job_id FROM jobs WHERE status = 'queued' ORDER BY job_id LIMIT 1)
  AND status = 'queued'
RETURNING job_id, order_id, worker;

UPDATE jobs
SET status = 'running', worker = 'C', lease_until = '2026-08-01T10:20'
WHERE job_id = (SELECT job_id FROM jobs
                WHERE status = 'queued' OR (status = 'running' AND lease_until < '2026-08-01T10:10')
                ORDER BY job_id LIMIT 1)
RETURNING job_id, worker;

UPDATE jobs SET status = 'done' WHERE job_id = 1 AND worker = 'A';
SELECT changes() AS a_finished;
UPDATE jobs SET status = 'done' WHERE job_id = 1 AND worker = 'C';
SELECT changes() AS c_finished;
