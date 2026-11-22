# Worked example A4 · A job queue that never runs a job twice

**Problem.** Several workers take jobs (send receipt e-mails) from a table. Two workers must never claim the same job, and a crashed worker's job must eventually be retried.

**Run:** `python tools/run_sql.py advanced/worked_examples/04_job_queue.sql`

## 1. Plan

```sql
CREATE TABLE jobs (
  job_id     INTEGER PRIMARY KEY,
  order_id   INTEGER NOT NULL,
  status     TEXT NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'running', 'done')),
  worker     TEXT,
  lease_until TEXT
);
CREATE INDEX idx_jobs_ready ON jobs(status, job_id);
INSERT INTO jobs (order_id) SELECT order_id FROM orders WHERE status = 'paid';
```

<!-- result -->
*Rows changed: 8*
<!-- /result -->

## 2. Tempting attempt: read, then claim

```sql norun
SELECT job_id FROM jobs WHERE status = 'queued' ORDER BY job_id LIMIT 1;   -- worker A and B both get job 1
UPDATE jobs SET status = 'running', worker = 'A' WHERE job_id = 1;        -- A
UPDATE jobs SET status = 'running', worker = 'B' WHERE job_id = 1;        -- B overwrites: job runs twice
```

Between the `SELECT` and the `UPDATE`, another worker can read the same row. This is the lost update from [lesson 03](../lessons/03_transactions_savepoints.md).

## 3. Fix: claim with one conditional UPDATE

Choose and claim in a **single statement** whose `WHERE` re-checks the status. `RETURNING` tells the worker which job it got:

```sql
UPDATE jobs
SET status = 'running', worker = 'A', lease_until = '2026-08-01T10:05'
WHERE job_id = (SELECT job_id FROM jobs WHERE status = 'queued' ORDER BY job_id LIMIT 1)
  AND status = 'queued'
RETURNING job_id, order_id, worker;
```

<!-- result -->
| job_id | order_id | worker |
|---|---|---|
| 1 | 101 | A |
<!-- /result -->

```sql
UPDATE jobs
SET status = 'running', worker = 'B', lease_until = '2026-08-01T10:05'
WHERE job_id = (SELECT job_id FROM jobs WHERE status = 'queued' ORDER BY job_id LIMIT 1)
  AND status = 'queued'
RETURNING job_id, order_id, worker;
```

<!-- result -->
| job_id | order_id | worker |
|---|---|---|
| 2 | 102 | B |
<!-- /result -->

Worker B gets the *next* job. If two claims ever raced for the same row, the `AND status = 'queued'` guard would let only one change it (0 rows changed for the loser, who simply tries again). In PostgreSQL the same idea is `… FOR UPDATE SKIP LOCKED` (see the [PostgreSQL labs](../postgresql/README.md)).

## 4. Crashed workers: leases

A worker that dies leaves its job `running`. The lease makes it claimable again after it expires:

```sql
UPDATE jobs
SET status = 'running', worker = 'C', lease_until = '2026-08-01T10:20'
WHERE job_id = (SELECT job_id FROM jobs
                WHERE status = 'queued' OR (status = 'running' AND lease_until < '2026-08-01T10:10')
                ORDER BY job_id LIMIT 1)
RETURNING job_id, worker;
```

<!-- result -->
| job_id | worker |
|---|---|
| 1 | C |
<!-- /result -->

At 10:10 job 1's lease has expired (worker A presumably crashed), so worker C takes it over. Finishing a job must check it still owns it:

```sql
UPDATE jobs SET status = 'done' WHERE job_id = 1 AND worker = 'A';
SELECT changes() AS a_finished;
UPDATE jobs SET status = 'done' WHERE job_id = 1 AND worker = 'C';
SELECT changes() AS c_finished;
```

<!-- result -->
*Rows changed: 0*

| a_finished |
|---|
| 0 |

*Rows changed: 1*

| c_finished |
|---|
| 1 |
<!-- /result -->

Worker A, coming back late, changes nothing, so the e-mail is marked done once. Sending the e-mail itself still needs an idempotency key (lesson [04](../lessons/04_upsert_idempotency.md)), because a worker can crash after sending and before marking it done.

**Practise next:** [PA27](../../practice/starter/PA27.sql), [PA28](../../practice/starter/PA28.sql).
