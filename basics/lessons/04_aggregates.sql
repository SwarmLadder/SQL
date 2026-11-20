SELECT COUNT(*) AS customer_count FROM customers;
SELECT MIN(unit_price_cents), MAX(unit_price_cents), AVG(unit_price_cents)
FROM products WHERE active = 1;
SELECT SUM(amount_cents) AS total_payments_cents FROM payments;
SELECT COUNT(*) AS paid_orders FROM orders WHERE status = 'paid';
