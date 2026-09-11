-- What traders pay for priority, by hour of day
--
-- Table:   pumpswap_all_swaps
-- Returns: percentiles of the requested prioritization fee per hour
--
-- provided_gas_fee is the submitted compute-unit price in micro-lamports per
-- compute unit, and provided_gas_limit is the submitted compute-unit limit, so
-- the prioritization fee a trader budgeted is their product divided by 1e6,
-- in lamports. consumed_gas is what the transaction actually used.
--
-- The limit is capped at Solana's 1.4M compute-unit maximum. A small share of
-- rows carries values far above it, up to 1.8e19, which is not a real budget
-- any transaction could submit. Without the cap they distort every average.

SELECT
    toHour(toTimeZone(block_time, 'UTC'))                                       AS hour_utc,
    count()                                                                     AS swaps,
    round(quantile(0.5)(provided_gas_fee * provided_gas_limit / 1e6 / 1e9), 6)  AS p50_priority_sol,
    round(quantile(0.9)(provided_gas_fee * provided_gas_limit / 1e6 / 1e9), 6)  AS p90_priority_sol,
    round(avg(consumed_gas / provided_gas_limit) * 100, 1)                      AS avg_cu_used_pct
FROM pumpswap_all_swaps
WHERE block_time > now() - INTERVAL 7 DAY
  AND provided_gas_limit BETWEEN 1 AND 1400000
GROUP BY hour_utc
ORDER BY hour_utc;

-- Note: figures are weighted by swap rows, not by transaction. A transaction
-- containing several swaps contributes its fee more than once.
