-- PA33: A keyed summary table  (advanced, script)
-- Create customer_month_revenue(customer_id INTEGER NOT NULL, month TEXT NOT NULL,
-- revenue_cents INTEGER NOT NULL, PRIMARY KEY (customer_id, month)) and fill it with paid
-- revenue (order lines of paid orders) per customer and month of ordered_at (YYYY-MM). The
-- checker then tries to insert a duplicate group.
--
-- Write a SQL script. End every statement with a semicolon.
-- Check:  python tools/practice.py check PA33
-- Hints:  python tools/practice.py hint PA33 1

