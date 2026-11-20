EXPLAIN QUERY PLAN
SELECT * FROM orders WHERE customer_id = 1 ORDER BY ordered_at;
EXPLAIN QUERY PLAN
SELECT * FROM order_items WHERE product_id = 3;
CREATE INDEX idx_customers_city ON customers(city);
EXPLAIN QUERY PLAN
SELECT customer_id, full_name FROM customers WHERE city = 'Bucharest';
SELECT name FROM sqlite_master WHERE type='index' ORDER BY name;
