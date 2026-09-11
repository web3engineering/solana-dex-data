-- Which programs route the flow
--
-- Table:   pumpswap_all_swaps
-- Returns: swap count and volume per calling program
--
-- parent_program is the program that invoked the swap instruction, so this is
-- the quickest way to see which routers, aggregators and bot contracts are
-- really sending flow to a venue.
--
-- An empty value is also the column default, so it covers both a genuinely
-- direct invocation and a row where the caller could not be determined. It is
-- labelled accordingly rather than counted as direct.

SELECT
    if(parent_program = '', 'direct or unattributed', parent_program) AS caller,
    count()                                                          AS swaps,
    round(sum(quote_token_amount) / 1e9, 1)                          AS sol_volume,
    round(count() / sum(count()) OVER () * 100, 1)                   AS pct_of_swaps
FROM pumpswap_all_swaps
WHERE block_time > now() - INTERVAL 7 DAY
  AND quote_token = 'So11111111111111111111111111111111111111112'
GROUP BY caller
ORDER BY swaps DESC
LIMIT 20;

-- Note: a multi-hop transaction produces one row per hop, so both the count
-- and the volume are per swap rather than per transaction.
