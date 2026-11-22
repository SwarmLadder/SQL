# 07 · Constraints and schema changes

> **You will learn** to encode business rules as `NOT NULL`, `UNIQUE` (single and composite), `CHECK` and `FOREIGN KEY` constraints, to choose `ON DELETE` behaviour, partial unique indexes, and to change a live schema safely with additive, reversible migrations and the expand/migrate/contract pattern.
> **Time:** about 60 minutes · **Before this:** [03 · Atomic changes and savepoints](03_transactions_savepoints.md)

Application code changes every week; data lives for years and is written by many programs. Rules that live **in the schema** are enforced for every writer, forever. Changing that schema while applications are running is a skill of its own.

**Run the whole lesson:** `python tools/run_sql.py advanced/lessons/07_constraints_migrations.sql`

## 1. The constraint toolbox

```sql
CREATE TABLE coupons (
  coupon_id   INTEGER PRIMARY KEY,
  code        TEXT    NOT NULL UNIQUE,
  percent_off INTEGER NOT NULL CHECK (percent_off BETWEEN 1 AND 90),
  starts_at   TEXT    NOT NULL,
  ends_at     TEXT    NOT NULL,
  CHECK (ends_at > starts_at)
);

INSERT INTO coupons (code, percent_off, starts_at, ends_at)
VALUES ('WELCOME10', 10, '2026-01-01', '2026-12-31');
SELECT coupon_id, code, percent_off FROM coupons;
```

<!-- result -->
*Rows changed: 1*

| coupon_id | code | percent_off |
|---|---|---|
| 1 | WELCOME10 | 10 |
<!-- /result -->

```sql error
INSERT INTO coupons (code, percent_off, starts_at, ends_at)
VALUES ('BACKWARDS', 10, '2026-12-31', '2026-01-01');
```

<!-- result -->
**Error:** `CHECK constraint failed: ends_at > starts_at`
<!-- /result -->

- A column-level `CHECK` tests one column; a table-level `CHECK` can relate several (`ends_at > starts_at`).
- `UNIQUE` allows several `NULL`s in SQLite and PostgreSQL (NULL ≠ NULL). If "required and unique" is the rule, add `NOT NULL`.
- Name important constraints (`CONSTRAINT coupon_dates CHECK (…)`) so error messages and migrations can refer to them.

## 2. Composite and partial uniqueness

**Composite:** a product may appear only once per order, which is what `PRIMARY KEY (order_id, product_id)` on `order_items` already says. Another example, one review per customer per product:

```sql
CREATE TABLE reviews (
  customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
  product_id  INTEGER NOT NULL REFERENCES products(product_id),
  stars       INTEGER NOT NULL CHECK (stars BETWEEN 1 AND 5),
  UNIQUE (customer_id, product_id)
);
INSERT INTO reviews VALUES (1, 3, 5), (2, 3, 4);
SELECT COUNT(*) AS reviews FROM reviews;
```

<!-- result -->
*Rows changed: 2*

| reviews |
|---|
| 2 |
<!-- /result -->

**Partial unique index:** uniqueness that applies only to some rows, such as "at most one *active* default address per customer":

```sql
CREATE TABLE addresses (
  address_id  INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  is_default  INTEGER NOT NULL DEFAULT 0 CHECK (is_default IN (0, 1))
);
CREATE UNIQUE INDEX one_default_address ON addresses(customer_id) WHERE is_default = 1;

INSERT INTO addresses (customer_id, is_default) VALUES (1, 1), (1, 0), (1, 0);
SELECT customer_id, SUM(is_default) AS defaults, COUNT(*) AS addresses FROM addresses GROUP BY customer_id;
```

<!-- result -->
*Rows changed: 3*

| customer_id | defaults | addresses |
|---|---|---|
| 1 | 1 | 3 |
<!-- /result -->

```sql error
INSERT INTO addresses (customer_id, is_default) VALUES (1, 1);
```

<!-- result -->
**Error:** `UNIQUE constraint failed: addresses.customer_id`
<!-- /result -->

## 3. Foreign keys and ON DELETE

What happens to children when a parent is deleted is a **business decision**:

| Option | Effect | Typical use |
|---|---|---|
| (default) `NO ACTION` / `RESTRICT` | the delete fails while children exist | orders, payments: never lose history |
| `CASCADE` | children are deleted too | order lines of a draft cart, attachments |
| `SET NULL` | the child's reference becomes NULL | optional links ("assigned to") |

```sql
CREATE TABLE carts (cart_id INTEGER PRIMARY KEY);
CREATE TABLE cart_lines (
  cart_id INTEGER NOT NULL REFERENCES carts(cart_id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL,
  PRIMARY KEY (cart_id, product_id)
);
INSERT INTO carts VALUES (1);
INSERT INTO cart_lines VALUES (1, 2), (1, 3);
DELETE FROM carts WHERE cart_id = 1;
SELECT COUNT(*) AS cart_lines_left FROM cart_lines;
```

<!-- result -->
*Rows changed: 1*

*Rows changed: 2*

*Rows changed: 1*

| cart_lines_left |
|---|
| 0 |
<!-- /result -->

SQLite enforces foreign keys only with `PRAGMA foreign_keys = ON` on **each connection**. The course runner sets it; your application must too.

## 4. Additive migrations

The safest schema change only **adds**: a new table, a nullable column, or a `NOT NULL` column **with a default**. Existing code that doesn't know about the change keeps working.

```sql
ALTER TABLE customers ADD COLUMN loyalty_tier TEXT NOT NULL DEFAULT 'standard'
  CHECK (loyalty_tier IN ('standard', 'silver', 'gold'));

-- Old-style insert, unaware of the new column: still works.
INSERT INTO customers (customer_id, full_name, email, city, joined_at)
VALUES (30, 'Old Client Code', 'old@example.test', 'Arad', '2026-09-01');

-- Backfill in a separate step.
UPDATE customers SET loyalty_tier = 'gold'
WHERE customer_id IN (SELECT o.customer_id FROM orders o JOIN order_items i ON i.order_id = o.order_id
                      WHERE o.status = 'paid' GROUP BY o.customer_id
                      HAVING SUM(i.quantity * i.unit_price_cents) >= 20000);

SELECT loyalty_tier, COUNT(*) AS customers FROM customers GROUP BY loyalty_tier ORDER BY loyalty_tier;
```

<!-- result -->
| loyalty_tier | customers |
|---|---|
| gold | 1 |
| standard | 8 |
<!-- /result -->

On large tables, backfill in **batches** (`WHERE customer_id BETWEEN …`) so no single transaction locks everything for minutes.

## 5. Expand → migrate → contract

Renaming or removing a column while old and new application versions run side by side can't be done in one step. Spread it over several deployments:

| Step | Schema | Old app version | New app version |
|---|---|---|---|
| 1. **Expand** | add `city_name` (nullable) | reads/writes `city` | writes **both**, reads `city` |
| 2. **Migrate** | backfill `city_name` from `city` in batches | unaffected | — |
| 3. **Switch** | — | retired | reads `city_name`, still writes both |
| 4. **Contract** | drop `city` (after a safe period) | — | uses only `city_name` |

Every step is reversible until the contract step, and the contract step happens only when nothing reads the old column. SQLite supports `ALTER TABLE … RENAME COLUMN` and `DROP COLUMN` (3.35+), but many changes (altering a constraint, changing a type) still require the "create new table, copy, swap" procedure from the SQLite documentation. PostgreSQL can do most changes in place, but some still take locks that block writes.

## 6. Migration checklist

- [ ] Additive first; destructive changes only after nothing uses the old shape.
- [ ] Each migration in a transaction (where the database allows DDL in transactions, as SQLite and PostgreSQL do).
- [ ] A tested **down** migration, or a written reason why it's irreversible.
- [ ] Rehearsed on a copy of production-sized data: duration, locks, disk.
- [ ] Backfills in batches, restartable, idempotent.
- [ ] New constraints validated against existing data **before** enforcing them.

## Common mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Rules only in application code | Another script writes invalid data | `NOT NULL`, `CHECK`, `UNIQUE`, `FOREIGN KEY` |
| `UNIQUE` on a nullable column meant to be required | Many NULL "duplicates" | Add `NOT NULL` |
| `ON DELETE CASCADE` on business history | Deleting a customer erases their orders | `RESTRICT`, or soft delete |
| Adding `NOT NULL` without a default | Migration fails or old inserts break | Add with a default, backfill, then tighten |
| Dropping or renaming in one deploy | Old app instances crash | Expand → migrate → contract |

## Your turn

<!-- exercises -->
Each exercise is graded on the course data **and** an edge-case fixture. Write your answer in `practice/starter/<ID>.sql`.

| ID | Exercise | Kind |
|---|---|---|
| `PA14` | **Constraints that reject bad data.** Create coupons(code TEXT, percent_off INTEGER, expires_at TEXT) where code is required and unique, percent_off is required and between 1 and 90, and expires_at is required. Insert one valid coupon: ('WELCOME10', 10, '2026-12-31'). The checker then tries five inserts, some of which must be rejected. | script |
| `PA15` | **Additive migration.** Add a column marketing_opt_in to customers that existing INSERT statements (which list only the original five columns) keep working with: integer, required, default 0, only 0 or 1 allowed. Then backfill it to 1 for customers who have at least one paid order. The checker inserts customers the old way and with a bad value. | script |
| `PA16` | **Plan a zero-downtime migration.** You must rename customers.city to customers.city_name while two versions of the application run at once. Write the expand/migrate/contract steps, what each application version reads and writes during each step, and how you would roll back at every point. | written ✍️ |
| `PA34` | **One review per customer and product.** Create reviews(customer_id, product_id, stars) where both IDs are required foreign keys, stars is required and between 1 and 5, and a customer can review a product only once. The checker tries five inserts. | script |
| `PA35` | **At most one default address.** Create addresses(address_id INTEGER PRIMARY KEY, customer_id INTEGER NOT NULL, is_default INTEGER NOT NULL DEFAULT 0 CHECK (is_default IN (0, 1))) and an index that allows any number of non-default addresses per customer but at most one default. The checker tries four inserts. | script |

```bash
python tools/practice.py show PA14
python tools/practice.py check PA14
python tools/practice.py hint PA14 1
```
<!-- /exercises -->

## Quick quiz

<!-- quiz -->
Answer in your head first, then check. The answers are stored as hashes, so reading the files won't spoil them.

**1.** A column is `UNIQUE` but nullable. How many rows may have NULL there?

   - **a)** One
   - **b)** Many
   - **c)** None

**2.** "At most one default address per customer" is best expressed as…

   - **a)** UNIQUE (customer_id, is_default)
   - **b)** a partial unique index WHERE is_default = 1
   - **c)** a CHECK constraint

**3.** Which ON DELETE option is wrong for orders that reference a customer?

   - **a)** RESTRICT
   - **b)** CASCADE
   - **c)** NO ACTION

**4.** How do you rename a column while old and new app versions both run?

   - **a)** ALTER TABLE RENAME COLUMN in one deploy
   - **b)** Expand, migrate, switch, then contract
   - **c)** Drop and recreate the table

```bash
python tools/quiz.py advanced/07 1 b      # question 1, answer b
python tools/quiz.py advanced/07           # list the questions
```
<!-- /quiz -->

## Summary

- Put business rules in the schema: `NOT NULL`, `UNIQUE`, `CHECK`, `FOREIGN KEY`.
- Composite `UNIQUE` for "once per pair"; partial unique indexes for "once among some rows".
- Choose `ON DELETE` deliberately; never cascade away history.
- Change live schemas additively; rename and remove with expand → migrate → contract.

**Next:** [08 · NULL, anti-joins, and query correctness](08_null_semantics.md)
