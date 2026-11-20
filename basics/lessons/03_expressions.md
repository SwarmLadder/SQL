# 03 · Types and expressions

**Learn**
- SQLite has flexible typing; choose explicit columns and constraints.
- Integer cents avoid floating-point errors in money arithmetic. `||` joins text.

**Run:** `python tools/run_sql.py basics/lessons/03_expressions.sql`

**Practice**
1. Produce SKU labels in the form `P01: Notebook`.
2. Compute 10% discount in integer cents (decide rounding).
3. Display names in uppercase using `UPPER`.

**Check:** Rounding display values does not change database storage.
