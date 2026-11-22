# Intermediate worked examples

Each example is a realistic problem solved step by step: **plan → tempting wrong attempt → why it fails → fix → test**. Every result shown was produced by running the example on the sample database. Run the whole example with `python tools/run_sql.py intermediate/worked_examples/<file>.sql`.

| # | Example | Problem |
|---|---|---|
| I1 | [ROW_NUMBER, RANK and DENSE_RANK on ties](01_rank_functions.md) | "Who has the second-highest salary in each team?" The answer depends on what you do with ties. |
| I2 | [A signup cohort table](02_cohort_pivot.md) | Product asks: "For each signup month, how many customers never ordered, paid once, or came back and paid again?" |
| I3 | [Buying streaks (gaps and islands)](03_gaps_and_islands.md) | Loyalty wants each customer's **streaks**: runs of consecutive months in which they placed an order. Ana ordering in January, February and March is one 3-month streak; a gap starts a new one. |
| I4 | [The median order value](04_median.md) | One big order makes the *average* order value misleading. Finance asks for the **median**: the middle value when orders are sorted. SQLite has no `MEDIAN()` function. |
| I5 | [An order funnel by month](05_funnel.md) | Product wants a funnel per month: how many orders were placed, how many got paid, how many were cancelled, and the conversion rate. All in **one** query, one row per month. |
| I6 | [A running balance from two kinds of events](06_running_balance.md) | Finance tracks money in (payments) and money out (refunds) in separate tables, and wants a single ledger with a **running balance** after every movement. |

Study an example **after** trying the related exercises; each one ends with *Practise next* links.
