-- How much of a token's own supply gets bought in the launch bundle
--
-- Table:   pumpfun_token_creation
-- Returns: distribution of bundle share across launches, by week
--
-- Useful as a launch-quality feature: a creator taking 30% of supply at t=0 is
-- a different setup from one taking nothing. Every wallet in a launch bundle
-- belongs to the creator, MEV bundles aside.
--
-- The first and last rows are partial weeks.

SELECT
    toStartOfWeek(block_time)                                 AS week,
    count()                                                   AS launches,
    round(quantile(0.5)(bundled_buys  / if(mayhem_mode = 1, 2e13, 1e13)), 1) AS p50_pct_supply,
    round(quantile(0.9)(bundled_buys  / if(mayhem_mode = 1, 2e13, 1e13)), 1) AS p90_pct_supply,
    round(countIf(bundled_buys = 0) / count() * 100, 1)        AS pct_no_bundle
FROM pumpfun_token_creation
WHERE block_time > now() - INTERVAL 90 DAY
GROUP BY week
ORDER BY week;
