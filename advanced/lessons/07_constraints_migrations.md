# 07 · Constraints and schema changes

**Learn**
- Use `NOT NULL`, `UNIQUE`, `CHECK`, and `FOREIGN KEY` constraints to enforce data rules.
- Schema migrations should be incremental, reversible when practical, and tested on copies of real data.

**Run:** `python tools/run_sql.py advanced/lessons/07_constraints_migrations.sql`

**Practice**
1. Create a table with a composite UNIQUE key.
2. Write an additive migration with a safe non-NULL default.
3. Explain what a migration plan should do before removing a populated column.

**Check:** SQLite ALTER TABLE differs from PostgreSQL; test each dialect independently.
