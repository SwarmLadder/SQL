WITH activity AS (
 SELECT customer_id,COUNT(*) AS all_orders,
        MIN(ordered_at) AS first_order,
        MAX(ordered_at) AS latest_order
 FROM orders GROUP BY customer_id
)
SELECT c.customer_id,c.full_name,c.joined_at,
       COALESCE(a.all_orders,0) AS order_count,
       a.first_order,a.latest_order
FROM customers c LEFT JOIN activity a ON a.customer_id=c.customer_id
ORDER BY c.customer_id;
WITH paid AS (
 SELECT customer_id,COUNT(*) AS paid_orders,
        MIN(ordered_at) AS first_paid_date
 FROM orders WHERE status='paid' GROUP BY customer_id
)
SELECT c.customer_id,c.full_name,
       COALESCE(p.paid_orders,0) AS paid_orders,
       SUBSTR(c.joined_at,1,7) AS signup_month,
       SUBSTR(p.first_paid_date,1,7) AS first_paid_month,
       CASE WHEN COALESCE(p.paid_orders,0) >= 2 THEN 1 ELSE 0 END AS repeat_paid_customer
FROM customers c LEFT JOIN paid p ON p.customer_id=c.customer_id
ORDER BY c.customer_id;
