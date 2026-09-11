# Solana query examples

Plain SQL you can paste into DBeaver, DataGrip, a Python client or curl. Each
file answers one question and carries a header comment explaining the tables it
touches and what it returns.

| File | Question |
| --- | --- |
| `01-top-creators-by-launches.sql` | Who launches the most tokens, and how much supply do they take |
| `02-bundle-share-of-supply.sql` | How bundle share is distributed across launches over time |
| `03-migrations-by-month.sql` | How many tokens reach the AMM each month, and how much SOL moves with them |
| `04-swaps-with-pool-reserves.sql` | Individual trades with pool state before and after |
| `05-daily-volume-by-venue.sql` | SOL volume per day across Pump.fun, PumpSwap and Meteora |
| `06-trade-size-distribution.sql` | Trade size percentiles per day |
| `07-priority-fees-by-hour.sql` | What traders pay for priority, by hour |
| `08-slippage-requested-vs-received.sql` | How far fills land from the submitted limit |
| `09-swaps-by-parent-program.sql` | Which programs route the flow |
| `10-table-coverage.sql` | Row counts and size of every table, plus how far one goes back |
| `11-unique-wallets.sql` | Unique wallets trading per day |

## Three things worth knowing

**Retention differs by table.** `pumpfun_token_creation` holds launches back to
January 2024. `pumpswap_all_swaps` and `pfamm_migrations` keep a rolling year,
`meteora_swaps` a rolling 90 days. The time windows in these files reflect that,
so widen them only where the data goes back.

**The server runs on America/Los_Angeles time.** Timestamp columns return
server time, not UTC. Wrap them in `toTimeZone(block_time, 'UTC')` whenever you
line the data up against anything else.

**Some tables deduplicate on merge.** `pumpfun_token_creation` is a
ReplacingMergeTree, so a recent window can still contain duplicate rows until
the parts merge. Add `FINAL` when you need exact counts, or drop duplicates
after reading.

## Getting access

Read-only credentials, $200/month per chain, one-week free trial.
[Request a trial](https://docs.google.com/forms/d/e/1FAIpQLSduVHVt51hEMGD2847Yj0rQTy1U5ogIgHPHutKyZth0ALhrwA/viewform)
or see the [docs](https://onchaindivers.com/).
