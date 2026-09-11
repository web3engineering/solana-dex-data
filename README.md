<div align="center">

# OnchainDivers

### Decoded blockchain trading data, straight from the database.

[![Docs](https://img.shields.io/badge/docs-onchaindivers.com-2a6df4?style=flat-square)](https://onchaindivers.com/)
[![Research](https://img.shields.io/badge/Substack-free%20research-ff6719?style=flat-square)](https://onchaindivers.substack.com/)
[![X](https://img.shields.io/badge/X-follow-000000?style=flat-square)](https://x.com/onchain_divers)
[![Free trial](https://img.shields.io/badge/Free%20trial-request-2ea043?style=flat-square)](https://docs.google.com/forms/d/e/1FAIpQLSduVHVt51hEMGD2847Yj0rQTy1U5ogIgHPHutKyZth0ALhrwA/viewform)

**16B+ rows · since January 2024 · 4 chains**

</div>

---

You get read-only ClickHouse credentials and connect with DBeaver, DataGrip,
Python, or anything else that speaks ClickHouse. There is no API layer in
between and nothing to ration: scan whole tables, JOIN across them, aggregate
server-side and pull back only the result.

This repository holds runnable examples. The SQL itself lives in `queries/`,
and the notebooks are committed with their output so you can see the data
without connecting to anything.

---

## Depth and coverage

| Network | Depth | What's in there |
| --- | --- | --- |
| **Solana** | Pump.fun launches since **Jan 2024**, one year rolling across the other venues | Pump.fun and Pump.fun v2, PumpSwap, Raydium (AMM, CPMM, Launchpad), Meteora DLMM and Dynamic Bonding Curve, token creation, AMM migrations, Jito tips, SOL and SPL transfers, blocks |
| **HyperLiquid** | since **July 2025** | Perpetual fills at block level with millisecond fill times, position before fill, realized PnL, fees, builder fees, liquidations, TWAP identifiers, plus raw order-book archives |
| **Polymarket** | since **2024**, order-book archives since **Feb 2026** | CTF Exchange fills with maker/taker side and full EVM transaction context, joined to event and market metadata: questions, resolution sources, categories, liquidity and volume |
| **Robinhood Chain** | since **May 2026** | Uniswap v3 and v4 pools and swaps: signed balance deltas, sqrt price and tick after each swap, in-range liquidity, pool fees and hooks |

Everything arrives decoded and typed rather than as raw logs you have to parse.
Every swap carries the execution context you need to model it properly: **pool
reserves before and after, priority fees and compute units, the parent program
that invoked the instruction, the fee payer, and slippage against the requested
amount.** Most providers give you a price and a size.

Full schemas, row counts and column descriptions live in the
[table reference](https://onchaindivers.com/solana/tables).

---

## What the data looks like

The ten most prolific Pump.fun creators of the last 30 days, and how much of
each token's supply they bought into their own launch bundle:

```sql
SELECT
    creator,
    count()                                                       AS launches,
    round(avg(bundled_buys_count), 1)                             AS avg_bundled_buys,
    round(avg(bundled_buys / if(mayhem_mode = 1, 2e13, 1e13)), 1) AS avg_bundle_pct_supply,
    toTimeZone(max(block_time), 'UTC')                            AS last_launch_utc
FROM pumpfun_token_creation
WHERE block_time > now() - INTERVAL 30 DAY
GROUP BY creator
ORDER BY launches DESC
LIMIT 10
```

| creator | launches | avg_bundled_buys | avg_bundle_pct_supply | last_launch_utc |
| --- | ---: | ---: | ---: | --- |
| `bwamJ…NfSXa` | 17,229 | 1.3 | 21.5 | 2026-09-01 04:36 |
| `7naFF…AMidP` | 5,264 | 4.0 | 30.2 | 2026-09-01 00:37 |
| `DmH2D…ygwcW` | 4,520 | 1.0 | 15.1 | 2026-08-28 06:46 |
| `EBx24…VwrcD` | 3,972 | 3.4 | 30.4 | 2026-09-01 03:11 |
| `AJNaS…fqvQ2` | 3,699 | 0.0 | 0.0 | 2026-08-31 23:07 |

One address launched 17,229 tokens in a month, roughly 570 a day, buying an
average of 21.5% of each token's supply into its own launch bundle. That
pattern is only visible if you hold the full launch history rather than a
rolling window.

Run against the live database on 1 September 2026. Addresses shortened for
display.

---

## What people build on it

**Machine learning.** Build features from decoded trade flow and labelled
launches. Pull training sets straight into a dataframe and iterate as often as
you like, without a request budget to manage.

**Backtesting.** Test signals against decoded trades and the order book as it
actually was at that moment rather than as it looks today. Cross-venue replay
lets you line up Polymarket and HyperLiquid on a single clock.

**Agents and automated research.** Point an agent at a SQL connection instead of
an API with quotas. It can explore the schema, write its own queries and follow
up on what it finds, iterating freely because the whole database sits behind one
credential and the documented schemas give it something stable to reason about.

**Research and monitoring.** Wallet and creator analysis, execution-quality
studies, scheduled reports, dashboards and alerts on the same tables.

---

## Getting access

**$200/month per chain.** Full access to that database, plus a direct support
channel with the people who built the schemas.

**One-week free trial** with the same access as a paid account. Same tables,
same limits.

[Request a trial](https://docs.google.com/forms/d/e/1FAIpQLSduVHVt51hEMGD2847Yj0rQTy1U5ogIgHPHutKyZth0ALhrwA/viewform)
· [Telegram](https://t.me/inventandchill)

Setup instructions, including DBeaver, are in the
[docs](https://onchaindivers.com/solana/getting-started).

---

## What's in this repository

```
queries/   plain .sql files, copy and run anywhere
solana/    notebooks: launches, creator behaviour, swaps with execution context
```

More networks and notebooks are being added.

---

## Research

We built these datasets for our own trading, then opened them up. Published
studies include comparisons of transaction-sending providers for Pump.fun,
PumpSwap and Meteora DLMM, a synchronized Bitcoin five-minute reconstruction
across Polymarket and HyperLiquid, and a wallet-fingerprint monitor that detects
when a tracked wallet changes its transaction builder.

Everything published is regenerated from the live database on each build, so
nothing on the site is hand-drawn.

[Read the research](https://onchaindivers.substack.com/)

---

## We also run Solana nodes

Research needs data. Execution needs nodes. We run both: gRPC feeds from
$200/month, plus shreds and preconfirmations for latency-sensitive trading
systems.

[Nodes and low-latency feeds](https://onchaindivers.com/solana-nodes)

---

MIT licensed. If you have questions, or need a protocol that isn't listed,
[open an issue](../../issues) or message us on
[Telegram](https://t.me/inventandchill).
