-- Top Pump.fun creators by number of token launches
--
-- Table:   pumpfun_token_creation
-- Returns: one row per creator, ordered by launch count
--
-- avg_bundle_pct_supply is the share of total supply the creator bought into
-- their own launch bundle. Only the creator can assemble that bundle, so the
-- wallets inside it belong to them even when the addresses differ. MEV bundles
-- are the exception, and they are rare enough not to move these numbers.
--
-- Mayhem launches carry twice the supply of standard ones (2e15 vs 1e15 raw
-- units at 6 decimals), so the divisor depends on mayhem_mode.

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
LIMIT 10;

-- Notes
--
-- creator is FixedString(48) and comes back NUL-padded. To get a clean address:
--     replaceAll(toString(creator), '\0', '') AS creator
--
-- The table is a ReplacingMergeTree. Rows are deduplicated on merge, so a
-- recent window can still contain duplicates. Add FINAL for exact counts:
--     FROM pumpfun_token_creation FINAL
