-- How many Pump.fun tokens completed migration to the AMM, by month
--
-- Table:   pfamm_migrations
-- Returns: one row per month with migration count and SOL moved
--
-- pfamm_migrations has a one-year TTL, so the window is capped accordingly.
-- A rolling 12-month filter lands in 13 calendar buckets, because the months
-- at either end are partial.

SELECT
    toStartOfMonth(block_time)          AS month,
    count()                             AS migrations,
    round(sum(sol_amount) / 1e9, 1)     AS total_sol,
    round(avg(sol_amount) / 1e9, 2)     AS avg_sol_per_migration
FROM pfamm_migrations
WHERE block_time > now() - INTERVAL 12 MONTH
GROUP BY month
ORDER BY month;
