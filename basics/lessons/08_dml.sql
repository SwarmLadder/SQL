INSERT INTO customers(customer_id, full_name, email, city, joined_at)
VALUES (99, 'Test Learner', 'learner@example.test', 'Brașov', '2026-11-20');
SELECT customer_id, city FROM customers WHERE customer_id = 99;
UPDATE customers SET city = 'Sibiu' WHERE customer_id = 99;
SELECT customer_id, city FROM customers WHERE customer_id = 99;
DELETE FROM customers WHERE customer_id = 99;
SELECT COUNT(*) AS remaining FROM customers WHERE customer_id = 99;
