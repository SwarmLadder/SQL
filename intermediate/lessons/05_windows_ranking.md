# 05 · Window functions and rankings

**Learn**
- `OVER (...)` computes across rows without collapsing them.
- `ROW_NUMBER`, `RANK`, and `DENSE_RANK` treat ties differently.

**Run:** `python tools/run_sql.py intermediate/lessons/05_windows_ranking.sql`

**Practice**
1. Find the two highest-paid people per team.
2. Compare RANK and DENSE_RANK on a dataset with ties.
3. Rank paid orders by their item total using a CTE.

**Check:** Decide how ties should be handled before choosing a ranking function.
