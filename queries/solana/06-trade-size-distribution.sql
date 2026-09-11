-- Distribution of trade size on PumpSwap, in SOL
--
-- Table:   pumpswap_all_swaps
-- Returns: percentiles of trade size per day
--
-- Medians and tails move differently. Watching them apart tells you whether
-- activity is being driven by retail flow or by a handful of large fills.

SELECT
    toDate(block_time)                                    AS day,
    count()                                               AS swaps,
    round(quantile(0.5)(quote_token_amount)  / 1e9, 3)    AS p50_sol,
    round(quantile(0.9)(quote_token_amount)  / 1e9, 3)    AS p90_sol,
    round(quantile(0.99)(quote_token_amount) / 1e9, 3)    AS p99_sol,
    round(max(quote_token_amount)            / 1e9, 2)    AS max_sol
FROM pumpswap_all_swaps
WHERE block_time > now() - INTERVAL 14 DAY
  AND quote_token = 'So11111111111111111111111111111111111111112'
GROUP BY day
ORDER BY day;

-- Notes
--
-- Daily maxima in the thousands of SOL are genuine rather than corrupt: the
-- pool reserve columns move to match them. Treat them as pool-draining
-- outliers rather than as representative trade sizes.
--
-- The first and last rows are partial days.
