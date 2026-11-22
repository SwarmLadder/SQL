-- PA37: Average of rated products  (advanced, query)
-- Start with WITH ratings(product_id, stars) AS (VALUES (1, 5), (1, NULL), (1, 3), (2,
-- NULL), (3, 4)). Return product_id, rated (number of non-NULL ratings) and avg_stars
-- (average of the non-NULL ratings, NULL if none) per product, sorted by product_id.
--
-- Write ONE read-only SELECT (or WITH ... SELECT) ending with a semicolon.
-- Check:  python tools/practice.py check PA37
-- Hints:  python tools/practice.py hint PA37 1

