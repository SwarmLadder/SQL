SELECT
  (SELECT COUNT(*) FROM (SELECT customer_id FROM orders WHERE status = 'pending'
                         UNION
                         SELECT customer_id FROM orders WHERE status = 'paid')) AS union_rows,
  (SELECT COUNT(*) FROM (SELECT customer_id FROM orders WHERE status = 'pending'
                         UNION ALL
                         SELECT customer_id FROM orders WHERE status = 'paid')) AS union_all_rows;
