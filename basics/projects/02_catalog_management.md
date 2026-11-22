# Safe Catalog Management

**Scenario.** Merchandising needs to add, re-price and retire products without ever damaging the live catalog. Every change must be previewed, checked and reversible.

**You'll use:** Basics lessons [08](../lessons/08_dml.md) (INSERT/UPDATE/DELETE, transactions) and [01](../lessons/01_where_null.md).

Work in your own file (for example `my_02_catalog_management.sql` in this folder) and run it with `python tools/run_sql.py`. Every run starts from a fresh sample database. The reference solution is [`02_catalog_management.sql`](02_catalog_management.sql); open it only after your own attempt.

## Tickets

### Ticket 1 · Add a product

Insert a new active product into an existing category with an explicit column list.

**Acceptance**

- The new row can be read back by its id.
- A second insert with the same sku is rejected by the database.

### Ticket 2 · Re-price safely

Change only that product's price.

**Acceptance**

- A `SELECT` with the same `WHERE` previews exactly one row.
- The `UPDATE` reports exactly one changed row.

### Ticket 3 · Clean up

Remove the test product again and prove nothing else changed.

**Acceptance**

- The product count is back to its starting value.
- The whole ticket runs inside a transaction you can roll back.

## Stretch goals

1. Add a category with two products, then raise prices only for the active one.
2. Undo the price rise with a savepoint while keeping the new category.
3. Try to delete a category that still has products and explain the error.

## Review rubric

| Dimension | Points | Evidence |
|---|---:|---|
| Correctness | 40 | Every ticket's acceptance criteria hold on a fresh database |
| Edge cases | 20 | You state and test at least one edge case per ticket (empty group, NULL, tie, unmatched row) |
| Query design | 15 | Right grain, right join type, no fan-out, deterministic ordering |
| Readability | 15 | One query per ticket, a comment with the question it answers, aliases that read well |
| Verification | 10 | At least one independent cross-check of a total |

**Done when** your file runs top to bottom with `python tools/run_sql.py <your file>`, every acceptance criterion is met, and you can explain each query out loud. Then compare with the reference solution and note one thing it does differently.
