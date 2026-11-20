# 08 · INSERT, UPDATE, DELETE

**Learn**
- `INSERT` adds rows, `UPDATE` changes matching rows, and `DELETE` removes rows.
- Always check the `WHERE` clause. This course runner uses a disposable in-memory database.

**Run:** `python tools/run_sql.py basics/lessons/08_dml.sql`

**Practice**
1. Add an inactive product using a new SKU.
2. Update only that new product's price.
3. Delete it and verify the number of removed rows.

**Check:** Never run an unscoped UPDATE or DELETE on real data.
