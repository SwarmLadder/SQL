# 07 · Text, dates, and grouped timelines

**Learn**
- SQLite stores this sample's dates as ISO-8601 text. `date`, `strftime`, and `substr` help analyze them.
- Timezone and timestamp semantics matter in real systems; the fixture uses dates only.

**Run:** `python tools/run_sql.py intermediate/lessons/07_dates_strings.sql`

**Practice**
1. Count customer signups by month.
2. Count orders per quarter in 2026.
3. Explain why UTC instants and local calendar dates should not be confused.

**Check:** Validate timezones and offsets outside this simple SQLite date-only example.
