SELECT customer_id, strftime('%Y-%m', joined_at) AS signup_month
FROM customers
ORDER BY customer_id;
