WITH ratings(product_id, stars) AS (VALUES (1, 5), (1, NULL), (1, 3), (2, NULL), (3, 4))
SELECT product_id, COUNT(stars) AS rated, AVG(stars) AS avg_stars
FROM ratings
GROUP BY product_id
ORDER BY product_id;
