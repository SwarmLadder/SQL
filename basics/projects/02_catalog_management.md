# Safe Catalog Management

**Deliverables**
- Insert a new product into an existing category.
- Update and query its price.
- Delete the test record and verify cleanup.

**Run:** `python tools/run_sql.py basics/projects/02_catalog_management.sql`

**Extend**
1. Add a category and two associated products.
2. Update only active products in that category.
3. Undo all test changes with a savepoint.

**Done when:** your queries run on a fresh database and results match the stated business definitions.
