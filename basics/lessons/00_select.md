# 00 · SELECT and columns

> **You will learn** how a table is organised, how to read the columns you need with `SELECT … FROM`, how to rename result columns with `AS`, and how `DISTINCT` removes repeated rows.
> **Time:** about 35 minutes · **Before this:** nothing. This is the first lesson.

Every question you ask a database starts the same way: *which table holds the facts, and which of its columns do I need?* In this lesson you learn to answer that with the most common SQL statement there is.

**Run the whole lesson:** `python tools/run_sql.py basics/lessons/00_select.sql`. Every run starts from a fresh copy of the [sample shop database](../../data/README.md), so you can't break anything.

## 1. Tables, rows and columns

A relational database stores data in **tables**. Each table has a fixed set of named **columns**, and holds any number of **rows**: one row per thing being described. The shop in this course has nine tables. The database itself can list them:

```sql
SELECT name
FROM sqlite_master
WHERE type = 'table'
ORDER BY name;
```

<!-- result -->
| name |
|---|
| audit_events |
| categories |
| customers |
| employees |
| order_items |
| orders |
| payments |
| products |
| teams |
<!-- /result -->

- `customers` has one row per customer, `orders` one row per order, `order_items` one row per *line* of an order.
- Each column has a type (`INTEGER`, `TEXT`) and rules, such as `NOT NULL` or `UNIQUE`. The full definitions are in [`data/schema.sql`](../../data/schema.sql).
- A table is a *set* of rows: it has no built-in order. You will see why that matters in lesson 02.

## 2. Choosing columns with SELECT … FROM

`SELECT` lists the columns you want; `FROM` names the table they come from. Columns appear in the result in the order you list them.

```sql
SELECT full_name, city
FROM customers;
```

<!-- result -->
| full_name | city |
|---|---|
| Ana Ionescu | Bucharest |
| Bogdan Pop | Cluj-Napoca |
| Carmen Radu | Iași |
| Darius Ene | Timișoara |
| Elena Stan | Brașov |
| Florin Matei | Constanța |
| Gabriela Dinu | Sibiu |
| Horia Vlad | Oradea |
<!-- /result -->

- You only get what you ask for. `customers` also has `email` and `joined_at`, but they are not in the result.
- Separate columns with commas. A missing comma is a classic error: `SELECT full_name city` silently means "`full_name`, renamed to `city`".
- SQL keywords are not case-sensitive (`select` = `SELECT`), but writing them in capitals makes queries easier to scan.
- End every statement with a semicolon. The course tools need it to know where a statement stops.

## 3. Renaming result columns with AS

`AS` gives a result column a new name, called an **alias**. The table is not changed; only this result is.

```sql
SELECT sku AS product_code,
       product_name AS name,
       unit_price_cents AS price_cents
FROM products;
```

<!-- result -->
| product_code | name | price_cents |
|---|---|---|
| P01 | Notebook | 1200 |
| P02 | Pen | 250 |
| P03 | Python Handbook | 4900 |
| P04 | Keyboard | 15900 |
| P05 | Desk Lamp | 8900 |
| P06 | Marker | 450 |
| P07 | SQL Handbook | 5500 |
| P08 | Mouse | 6500 |
| P09 | Folder | 350 |
<!-- /result -->

- Aliases make results readable for whoever consumes them: a report, an API response, a spreadsheet.
- Applications often read columns by name, so a stable alias is part of your query's contract.
- An alias that contains spaces needs double quotes (`AS "unit price"`). Prefer `snake_case` and skip the quotes.

## 4. DISTINCT removes repeated rows

Many orders share a status. To see each *value* once, put `DISTINCT` right after `SELECT`:

```sql
SELECT DISTINCT status
FROM orders;
```

<!-- result -->
| status |
|---|
| paid |
| pending |
| cancelled |
<!-- /result -->

`DISTINCT` compares **whole result rows**, not single columns. With two columns you get each distinct *combination*:

```sql
SELECT DISTINCT category_id, active
FROM products
ORDER BY category_id, active;
```

<!-- result -->
| category_id | active |
|---|---|
| 1 | 1 |
| 2 | 0 |
| 2 | 1 |
| 3 | 1 |
| 4 | 1 |
<!-- /result -->

Category 2 (Stationery) appears twice because it has both active and inactive products.

## 5. Why not `SELECT *`?

`SELECT *` returns every column. It's handy for a first look at a table:

```sql
SELECT *
FROM categories;
```

<!-- result -->
| category_id | category_name |
|---|---|
| 1 | Books |
| 2 | Stationery |
| 3 | Electronics |
| 4 | Home |
<!-- /result -->

Avoid it in queries that other code depends on:

- If someone adds a column (say, a large `description`), every `SELECT *` query suddenly returns more data.
- Code that reads columns by position breaks when the column order changes.
- Readers can't tell which columns the query actually needs.

## Common mistakes

| Mistake | What happens | Fix |
|---|---|---|
| `SELECT full_name city FROM customers;` | One column, named `city`, containing names | Put a comma between columns |
| Expecting `AS` to rename the table's column | The table keeps its name; only the result changes | Use `ALTER TABLE … RENAME COLUMN` if you really mean the schema |
| `SELECT DISTINCT status, order_id …` to get distinct statuses | Every row is distinct because `order_id` differs | Select only the columns whose combinations you want |
| Relying on the order rows come back in | Order can change between runs or databases | Add `ORDER BY` (lesson 02) |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PB01` | **Active catalog.** Return sku, product_name for every active product (active = 1), sorted by sku. | query |
| `PB02` | **Customer labels.** Return customer_id and the customer's full name under the alias customer_label, sorted by customer_id. The column names are checked. | query |
| `PB03` | **Distinct order statuses.** Return each order status once, in a column named status, sorted alphabetically. | query |
| `PB21` | **Customer directory.** Return full_name, email, city for every customer, sorted by full_name. | query |
| `PB22` | **Cities we ship to.** Return each customer city once, in a column named city, sorted alphabetically. | query |
| `PB23` | **Category and active pairs.** Return each distinct combination of category_id and active from products, sorted by category_id then active. | query |

```bash
python tools/practice.py show PB01
python tools/practice.py check PB01
python tools/practice.py hint PB01 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** What does `SELECT full_name city FROM customers;` return?

   - **a)** Two columns, full_name and city
   - **b)** One column of names, labelled city
   - **c)** A syntax error

**2.** After `SELECT sku AS product_code FROM products;`, what is the column called in the products table?

   - **a)** sku
   - **b)** product_code
   - **c)** Both names work from now on

**3.** `SELECT DISTINCT category_id, active FROM products;` removes rows that are duplicated in…

   - **a)** category_id only
   - **b)** active only
   - **c)** the combination of category_id and active

**4.** Why avoid `SELECT *` in application queries?

   - **a)** It is slower to type
   - **b)** Its result changes when the table's columns change
   - **c)** SQLite does not support it

```bash
python tools/quiz.py basics/00 1 b      # question 1, answer b
python tools/quiz.py basics/00           # list the questions
```
<!-- /quiz -->

## Summary

- A table has named columns and holds rows; it has no built-in order.
- `SELECT columns FROM table;` returns only the columns you list, in that order.
- `AS` renames a column in the result only.
- `DISTINCT` removes duplicate *result rows*, comparing all selected columns.
- Use `SELECT *` to explore, not in code that others rely on.

**Next:** [01 · WHERE, comparisons, and NULL](01_where_null.md)
