# Advanced worked examples

Each example is a realistic problem solved step by step: **plan → tempting wrong attempt → why it fails → fix → test**. Every result shown was produced by running the example on the sample database. Run the whole example with `python tools/run_sql.py advanced/worked_examples/<file>.sql`.

| # | Example | Problem |
|---|---|---|
| A1 | [From SCAN to SEARCH](01_scan_to_search.md) | An operations screen polls `SELECT order_id, customer_id, ordered_at FROM orders WHERE status = 'pending' ORDER BY ordered_at DESC LIMIT 20` every few seconds. Make it cheap without changing its result. |
| A2 | [Remove duplicate events, then make them impossible](02_dedupe_events.md) | A retrying webhook stored `order_paid` for order 101 three times. Clean it up and stop it happening again. |
| A3 | [Rolling revenue up a category tree](03_tree_rollup.md) | The shop is reorganising its catalogue into a tree (Books → Programming Books, Office → Stationery …). Management wants revenue **per node including everything below it**. |
| A4 | [A job queue that never runs a job twice](04_job_queue.md) | Several workers take jobs (send receipt e-mails) from a table. Two workers must never claim the same job, and a crashed worker's job must eventually be retried. |
| A5 | [A backfill in batches](05_batched_backfill.md) | A new column `customers.lifetime_cents` must be filled for every existing customer. On a table with millions of rows, one giant `UPDATE` would lock writes for minutes. Do it in small, restartable batches. |
| A6 | [Prices as of a date](06_price_as_of.md) | Products change price over time. Analysts ask: "What was the list price of each product **on the day each order was placed**, and did any order line get charged something different?" |

Study an example **after** trying the related exercises; each one ends with *Practise next* links.
