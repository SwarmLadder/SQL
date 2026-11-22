-- Worked example B2: each customer's first order (id and date), one row per customer.

-- Attempt 1 (misleading): SQLite accepts a bare column next to MIN(), and in SQLite it
-- happens to come from the MIN row. Other databases reject it, and with two MIN() calls
-- or ties the result is undefined. Don't rely on it.
SELECT customer_id, order_id, MIN(ordered_at) AS first_ordered_at
FROM orders
GROUP BY customer_id
ORDER BY customer_id;

-- Attempt 2 (portable): find the first date per customer, then join back to get the order.
-- Ties on the same day are broken by the lowest order_id.
SELECT o.customer_id, MIN(o.order_id) AS first_order_id, o.ordered_at AS first_ordered_at
FROM orders o
JOIN (SELECT customer_id, MIN(ordered_at) AS first_at FROM orders GROUP BY customer_id) f
  ON f.customer_id = o.customer_id AND f.first_at = o.ordered_at
GROUP BY o.customer_id, o.ordered_at
ORDER BY o.customer_id;
