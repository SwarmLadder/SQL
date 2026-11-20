SELECT SUBSTR(created_at,1,7) AS month,event_type,COUNT(*) AS event_count FROM audit_events GROUP BY SUBSTR(created_at,1,7),event_type ORDER BY month,event_type;
