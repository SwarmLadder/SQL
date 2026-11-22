WITH stored(request_key, request_hash) AS (VALUES ('req-1','h1'), ('req-2','h2')),
incoming(request_key, request_hash) AS (VALUES ('req-1','h1'), ('req-2','hX'), ('req-3','h3'))
SELECT i.request_key,
  CASE
    WHEN s.request_key IS NULL THEN 'new'
    WHEN s.request_hash = i.request_hash THEN 'replay'
    ELSE 'conflict'
  END AS decision
FROM incoming i
LEFT JOIN stored s ON s.request_key = i.request_key
ORDER BY i.request_key;
