# Worked example B6 · Pagination that doesn't skip rows

**Problem.** The product list shows 3 products per page, cheapest first. Customers report a product appearing on two pages while another never appears.

**Run:** `python tools/run_sql.py basics/worked_examples/06_stable_pagination.sql`

## 1. Reproduce it

Ties cause it. Add two products with the same price as existing ones:

```sql
INSERT INTO products (product_id, sku, category_id, product_name, unit_price_cents) VALUES
  (20, 'P20', 2, 'Eraser', 450),
  (21, 'P21', 2, 'Ruler',  450);
```

<!-- result -->
*Rows changed: 2*
<!-- /result -->

## 2. Tempting attempt

```sql
SELECT sku, unit_price_cents FROM products
WHERE active = 1
ORDER BY unit_price_cents
LIMIT 3 OFFSET 0;
```

<!-- result -->
| sku | unit_price_cents |
|---|---|
| P02 | 250 |
| P06 | 450 |
| P20 | 450 |
<!-- /result -->

```sql
SELECT sku, unit_price_cents FROM products
WHERE active = 1
ORDER BY unit_price_cents
LIMIT 3 OFFSET 3;
```

<!-- result -->
| sku | unit_price_cents |
|---|---|
| P21 | 450 |
| P01 | 1200 |
| P03 | 4900 |
<!-- /result -->

Three products cost 450. `ORDER BY unit_price_cents` doesn't say in which order *they* come, so each page query is free to order them differently. On this run they may look fine, but nothing guarantees it. A different plan, an index or more data can change the order between the two requests.

## 3. Fix: a unique tie-breaker

```sql
SELECT sku, unit_price_cents FROM products
WHERE active = 1
ORDER BY unit_price_cents, sku
LIMIT 3 OFFSET 0;
```

<!-- result -->
| sku | unit_price_cents |
|---|---|
| P02 | 250 |
| P06 | 450 |
| P20 | 450 |
<!-- /result -->

```sql
SELECT sku, unit_price_cents FROM products
WHERE active = 1
ORDER BY unit_price_cents, sku
LIMIT 3 OFFSET 3;
```

<!-- result -->
| sku | unit_price_cents |
|---|---|
| P21 | 450 |
| P01 | 1200 |
| P03 | 4900 |
<!-- /result -->

`sku` is unique, so `(unit_price_cents, sku)` puts every row in exactly one position, and the pages partition the list.

## 4. Test it

Concatenate all pages and compare with the full sorted list. Every product must appear exactly once:

```sql
SELECT COUNT(*) AS listed, COUNT(DISTINCT sku) AS distinct_listed
FROM (SELECT sku FROM (SELECT sku FROM products WHERE active = 1 ORDER BY unit_price_cents, sku LIMIT 3 OFFSET 0)
      UNION ALL
      SELECT sku FROM (SELECT sku FROM products WHERE active = 1 ORDER BY unit_price_cents, sku LIMIT 3 OFFSET 3)
      UNION ALL
      SELECT sku FROM (SELECT sku FROM products WHERE active = 1 ORDER BY unit_price_cents, sku LIMIT 3 OFFSET 6)
      UNION ALL
      SELECT sku FROM (SELECT sku FROM products WHERE active = 1 ORDER BY unit_price_cents, sku LIMIT 3 OFFSET 9));
```

<!-- result -->
| listed | distinct_listed |
|---|---|
| 10 | 10 |
<!-- /result -->

`listed = distinct_listed = 10` (all active products, none twice). For big tables or lists that change while people page, use keyset pagination ([Advanced 01](../../advanced/lessons/01_query_rewrites.md)).

**Practise next:** [PB27](../../practice/starter/PB27.sql), [PB28](../../practice/starter/PB28.sql), [PA22](../../practice/starter/PA22.sql).
