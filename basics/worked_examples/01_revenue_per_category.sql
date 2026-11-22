-- Worked example B1: paid revenue per category, keeping empty categories.
-- Add a category with no products (inside a transaction, so the dataset is untouched).
BEGIN;
INSERT INTO categories VALUES (99, 'Garden');

-- Attempt 1 (wrong): the WHERE on orders turns the LEFT JOIN back into an inner join,
-- so Garden disappears.
SELECT c.category_name, SUM(i.quantity * i.unit_price_cents) AS revenue_cents
FROM categories c
LEFT JOIN products p ON p.category_id = c.category_id
LEFT JOIN order_items i ON i.product_id = p.product_id
LEFT JOIN orders o ON o.order_id = i.order_id
WHERE o.status = 'paid'
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;

-- Attempt 2 (right): count only paid lines inside the aggregate, and COALESCE NULL to 0.
SELECT c.category_name,
       COALESCE(SUM(CASE WHEN o.status = 'paid' THEN i.quantity * i.unit_price_cents END), 0) AS revenue_cents
FROM categories c
LEFT JOIN products p ON p.category_id = c.category_id
LEFT JOIN order_items i ON i.product_id = p.product_id
LEFT JOIN orders o ON o.order_id = i.order_id
GROUP BY c.category_id, c.category_name
ORDER BY c.category_name;
ROLLBACK;
