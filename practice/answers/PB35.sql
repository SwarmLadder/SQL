SELECT full_name, LENGTH(full_name) AS name_length
FROM customers
ORDER BY name_length DESC, full_name;
