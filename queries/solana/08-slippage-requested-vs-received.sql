-- How much room fills leave against the bound the trader submitted
--
-- Table:   pumpswap_all_swaps
-- Returns: headroom percentiles per day, split by direction
--
-- quote_token_amount_limit means different things depending on the trade:
--   normal buy        max quote amount in   -> actual spend lands at or below it
--   sell              min quote amount out  -> actual proceeds land at or above it
--   exact-quote buy   the exact amount in   -> actual always equals the limit,
--                     because the real bound is on the base token instead
--
-- Exact-quote rows are excluded, since their headroom is mechanically zero and
-- their protection is expressed in base tokens. Directions are kept apart
-- rather than merged, because the two bounds point in opposite directions.
--
-- Bounds below 0.001 SOL are dropped: traders who submit a token minimum of
-- effectively zero produce enormous percentages that say nothing about the fill.

SELECT
    toDate(block_time)  AS day,
    direction,
    count()             AS swaps,
    round(quantile(0.5)(abs(quote_token_amount - quote_token_amount_limit)
          / quote_token_amount_limit) * 100, 2)  AS p50_headroom_pct,
    round(quantile(0.9)(abs(quote_token_amount - quote_token_amount_limit)
          / quote_token_amount_limit) * 100, 2)  AS p90_headroom_pct
FROM pumpswap_all_swaps
WHERE block_time > now() - INTERVAL 7 DAY
  AND quote_token = 'So11111111111111111111111111111111111111112'
  AND is_exact_quote = 0
  AND quote_token_amount_limit > 1000000
GROUP BY day, direction
ORDER BY day, direction;
