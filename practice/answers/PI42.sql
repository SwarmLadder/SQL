SELECT customer_id, SUBSTR(email, 1, INSTR(email, '@') - 1) AS local_part
FROM customers
ORDER BY customer_id;
