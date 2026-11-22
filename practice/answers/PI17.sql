CREATE VIEW paid_customer_totals AS
SELECT o.customer_id, SUM(p.amount_cents) AS lifetime_cents
FROM payments p
JOIN orders o ON o.order_id = p.order_id
GROUP BY o.customer_id;
