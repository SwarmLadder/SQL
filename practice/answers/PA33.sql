CREATE TABLE customer_month_revenue (
  customer_id INTEGER NOT NULL,
  month TEXT NOT NULL,
  revenue_cents INTEGER NOT NULL,
  PRIMARY KEY (customer_id, month)
);
INSERT INTO customer_month_revenue
SELECT o.customer_id, strftime('%Y-%m', o.ordered_at), SUM(i.quantity * i.unit_price_cents)
FROM orders o JOIN order_items i ON i.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.customer_id, strftime('%Y-%m', o.ordered_at);
