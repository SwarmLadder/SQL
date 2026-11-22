-- PA31: Paid orders can't be deleted  (advanced, script)
-- Create a trigger that rejects, with RAISE(ABORT, …), any DELETE of an order whose status
-- is 'paid'. Other orders may still be deleted. The checker deletes an order's children
-- and then the order, for one paid and one cancelled order.
--
-- Write a SQL script. End every statement with a semicolon.
-- Check:  python tools/practice.py check PA31
-- Hints:  python tools/practice.py hint PA31 1

