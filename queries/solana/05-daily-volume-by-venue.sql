-- Daily SOL-denominated volume across Solana venues
--
-- Tables:  pumpfun_all_swaps, pumpswap_all_swaps, meteora_swaps
-- Returns: one row per day per venue
--
-- Only SOL-quoted trades are counted, so the venues are comparable.
-- pumpfun_all_swaps is SOL-quoted throughout, so quote_coin_amount is already
-- in lamports. PumpSwap is filtered to the wrapped-SOL mint.
--
-- Meteora needs more care. In meteora_swaps the amount columns are the input
-- and output of the trade rather than fixed sides of the pair, so which one
-- holds SOL depends on swap_for_y. Summing quote_coin_amount unconditionally
-- treats the token amount as lamports on half the rows, which is how you end
-- up with billions of SOL a day.
--
-- The UNION is wrapped in a subquery: ORDER BY applied directly to a UNION ALL
-- is resolved per branch rather than over the combined result.

SELECT *
FROM
(
    SELECT 'pumpfun' AS venue,
           toDate(block_time) AS day,
           count()            AS swaps,
           round(sum(quote_coin_amount) / 1e9, 1) AS sol_volume
    FROM pumpfun_all_swaps
    WHERE block_time > now() - INTERVAL 30 DAY
    GROUP BY day

    UNION ALL

    SELECT 'pumpswap',
           toDate(block_time),
           count(),
           round(sum(quote_token_amount) / 1e9, 1)
    FROM pumpswap_all_swaps
    WHERE block_time > now() - INTERVAL 30 DAY
      AND quote_token = 'So11111111111111111111111111111111111111112'
    GROUP BY toDate(block_time)

    UNION ALL

    SELECT 'meteora',
           toDate(block_time),
           count(),
           round(sum(toUInt128(if(swap_for_y = 1, quote_coin_amount, base_coin_amount))) / 1e9, 1)
    FROM meteora_swaps
    WHERE block_time > now() - INTERVAL 30 DAY
      AND quote_coin = 'So11111111111111111111111111111111111111112'
    GROUP BY toDate(block_time)
)
ORDER BY day, venue;

-- Notes
--
-- This is gross traded notional. For the net WSOL moving in and out of a
-- Meteora vault, subtract host_fee on the swap_for_y = 0 side.
--
-- Each row is one swap instruction, so a routed transaction contributes once
-- per hop.
--
-- meteora_swaps keeps a rolling 90 days, so its series is shorter than the
-- other two on longer windows.
--
-- The first and last days of the window are partial.
