# Basics worked examples

Each example is a realistic problem solved step by step: **plan → tempting wrong attempt → why it fails → fix → test**. Every result shown was produced by running the example on the sample database. Run the whole example with `python tools/run_sql.py basics/worked_examples/<file>.sql`.

| # | Example | Problem |
|---|---|---|
| B1 | [Revenue per category, keeping empty categories](01_revenue_per_category.md) | Report paid revenue for *every* category, with 0 for categories that sold nothing. |
| B2 | [Each customer's first order](02_first_order.md) | Return one row per customer with the id and date of their first order. |
| B3 | [Finding duplicate customers](03_find_duplicates.md) | Marketing suspects some people signed up twice with differently-written emails. Find them before a campaign sends two copies. |
| B4 | [Percentages that aren't zero](04_percentages.md) | "What percentage of our orders were paid?" A one-line question that produces a wrong answer surprisingly often. |
| B5 | [Customers who bought from both categories](05_bought_both.md) | Cross-selling wants customers who have bought **both** Books **and** Electronics (in paid orders). |
| B6 | [Pagination that doesn't skip rows](06_stable_pagination.md) | The product list shows 3 products per page, cheapest first. Customers report a product appearing on two pages while another never appears. |

Study an example **after** trying the related exercises; each one ends with *Practise next* links.
