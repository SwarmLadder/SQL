WITH category_revenue AS (
  SELECT c.category_name, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
  FROM order_items i
  JOIN orders o ON o.order_id = i.order_id AND o.status = 'paid'
  JOIN products p ON p.product_id = i.product_id
  JOIN categories c ON c.category_id = p.category_id
  GROUP BY c.category_id, c.category_name
)
SELECT category_name, revenue_cents,
  ROUND(100.0 * revenue_cents / SUM(revenue_cents) OVER (), 1) AS share_pct
FROM category_revenue
ORDER BY revenue_cents DESC, category_name;
