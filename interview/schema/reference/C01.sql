CREATE TABLE accounts(account_id INTEGER PRIMARY KEY,email TEXT NOT NULL UNIQUE,balance_cents INTEGER NOT NULL CHECK(balance_cents>=0));
