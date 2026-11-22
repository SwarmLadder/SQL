UPDATE orders
SET status = 'cancelled'
WHERE status = 'pending' AND ordered_at < '2026-04-01';
