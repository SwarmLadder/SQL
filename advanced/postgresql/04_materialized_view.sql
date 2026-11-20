-- PostgreSQL only. Transaction rollback removes demo objects after execution.
BEGIN;
CREATE TABLE demo_mv_sales_swarm (category TEXT, amount INTEGER);
INSERT INTO demo_mv_sales_swarm VALUES ('books',100),('books',200),('pens',25);
CREATE MATERIALIZED VIEW demo_mv_totals_swarm AS
SELECT category,SUM(amount) AS amount FROM demo_mv_sales_swarm GROUP BY category;
SELECT * FROM demo_mv_totals_swarm ORDER BY category;
INSERT INTO demo_mv_sales_swarm VALUES ('books',50);
REFRESH MATERIALIZED VIEW demo_mv_totals_swarm;
SELECT * FROM demo_mv_totals_swarm ORDER BY category;
ROLLBACK;
