CREATE TABLE jobs(job_id INTEGER PRIMARY KEY,tenant_id TEXT NOT NULL,status TEXT NOT NULL CHECK(status IN('queued','processing','done')),attempt_count INTEGER NOT NULL DEFAULT 0 CHECK(attempt_count>=0),created_at TEXT NOT NULL);
CREATE INDEX idx_jobs_claim ON jobs(status,created_at,job_id);
