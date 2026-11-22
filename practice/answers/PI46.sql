CREATE VIEW monthly_paid_revenue AS
SELECT strftime('%Y-%m', o.ordered_at) AS month,
       SUM(i.quantity * i.unit_price_cents) AS revenue_cents
FROM orders o
JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY month;
