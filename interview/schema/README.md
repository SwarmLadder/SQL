# Schema Design Interviews

Four automated DDL challenges. Write tables, constraints and indexes; tests attempt valid and invalid operations.

| ID | Scenario |
|---|---|
| C01 | Customer balances: unique keys and CHECK |
| C02 | One active reservation per tenant/resource |
| C03 | Job queue schema and claim index |
| C04 | Tenant-scoped webhook inbox/outbox |

```bash
python tools/schema_practice.py list
python tools/schema_practice.py check C01 interview/schema/starter/C01.sql
python tools/schema_practice.py verify-reference
```

Edit a starter file before checking. Reference DDL is in [reference/](reference/).

Checks run in fresh in-memory SQLite. This tool is for **trusted local practice scripts**, not for executing arbitrary untrusted SQL.
