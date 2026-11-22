# Worked example B3 · Finding duplicate customers

**Problem.** Marketing suspects some people signed up twice with differently-written emails. Find them before a campaign sends two copies.

**Run:** `python tools/run_sql.py basics/worked_examples/03_find_duplicates.sql`

## 1. Plan

Duplicates are rows that are *the same thing* written differently. Decide what "the same" means first: here, the same email ignoring upper/lower case and surrounding spaces. `email` is `UNIQUE`, but that only rejects *identical* text. Add two sneaky sign-ups to see the problem:

```sql
INSERT INTO customers (customer_id, full_name, email, city, joined_at) VALUES
  (20, 'Ana I.',     'ANA@example.test',     'Bucharest', '2026-08-01'),
  (21, 'Bogdan Pop', ' bogdan@example.test', 'Cluj-Napoca', '2026-08-02');
```

<!-- result -->
*Rows changed: 2*
<!-- /result -->

## 2. Tempting attempt

```sql
SELECT email, COUNT(*) AS copies
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;
```

<!-- result -->
| email | copies |
|---|---|
| *(no rows)* |  |
<!-- /result -->

Nothing is found: `'ANA@example.test'` and `'ana@example.test'` are different text, so they land in different groups.

## 3. Fix: group by the normalised value

```sql
SELECT LOWER(TRIM(email)) AS normalised_email,
       COUNT(*) AS copies,
       MIN(customer_id) AS keep_id,
       MAX(customer_id) AS duplicate_id
FROM customers
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1
ORDER BY normalised_email;
```

<!-- result -->
| normalised_email | copies | keep_id | duplicate_id |
|---|---|---|---|
| ana@example.test | 2 | 1 | 20 |
| bogdan@example.test | 2 | 2 | 21 |
<!-- /result -->

To review the actual rows, join back on the same expression:

```sql
SELECT c.customer_id, c.full_name, c.email, c.joined_at
FROM customers c
WHERE LOWER(TRIM(c.email)) IN (SELECT LOWER(TRIM(email)) FROM customers
                               GROUP BY LOWER(TRIM(email)) HAVING COUNT(*) > 1)
ORDER BY LOWER(TRIM(c.email)), c.customer_id;
```

<!-- result -->
| customer_id | full_name | email | joined_at |
|---|---|---|---|
| 1 | Ana Ionescu | ana@example.test | 2026-01-05 |
| 20 | Ana I. | ANA@example.test | 2026-08-01 |
| 2 | Bogdan Pop | bogdan@example.test | 2026-01-15 |
| 21 | Bogdan Pop |  bogdan@example.test | 2026-08-02 |
<!-- /result -->

## 4. Test it, then prevent it

| Case | Expected |
|---|---|
| Same email, different case | found (Ana) |
| Leading space | found (Bogdan) |
| Genuinely different emails | not reported |

Finding duplicates is clean-up. *Preventing* them belongs in the schema: store emails normalised on write, or add a unique index on the expression, `CREATE UNIQUE INDEX … ON customers(LOWER(TRIM(email)))` (lesson [Advanced 07](../../advanced/lessons/07_constraints_migrations.md)).

**Practise next:** [PB22](../../practice/starter/PB22.sql), [PB39](../../practice/starter/PB39.sql).
