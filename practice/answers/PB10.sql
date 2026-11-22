SELECT
  (SELECT COUNT(*) FROM customers) AS customer_count,
  (SELECT COUNT(*) FROM products) AS product_count;
