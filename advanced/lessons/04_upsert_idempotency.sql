CREATE TABLE request_results (
  request_id TEXT PRIMARY KEY,
  payload TEXT NOT NULL,
  result TEXT NOT NULL
);
INSERT INTO request_results(request_id,payload,result)
VALUES ('req-1','quantity=2','accepted');
INSERT INTO request_results(request_id,payload,result)
VALUES ('req-1','quantity=2','accepted')
ON CONFLICT(request_id) DO NOTHING;
SELECT * FROM request_results ORDER BY request_id;
CREATE TABLE counters (
  category TEXT PRIMARY KEY,
  total INTEGER NOT NULL CHECK(total>=0)
);
INSERT INTO counters(category,total) VALUES ('books',5);
INSERT INTO counters(category,total) VALUES ('books',3)
ON CONFLICT(category) DO UPDATE SET total=counters.total+excluded.total;
SELECT * FROM counters;
