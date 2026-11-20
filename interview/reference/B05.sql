SELECT c.category_name,COUNT(p.product_id) AS product_count FROM categories c LEFT JOIN products p ON p.category_id=c.category_id GROUP BY c.category_id,c.category_name ORDER BY c.category_name;
