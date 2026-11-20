-- JSON field access for an operational audit report (SQLite JSON functions).
SELECT event_type,COUNT(*) AS events
FROM audit_events GROUP BY event_type ORDER BY event_type;
SELECT event_id,event_type,
       json_extract(payload_json,'$.order_id') AS order_id
FROM audit_events
WHERE json_valid(payload_json)=1
ORDER BY event_id;
