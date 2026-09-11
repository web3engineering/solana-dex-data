-- Unique wallets trading per day, by venue
--
-- Tables:  pumpfun_all_swaps, pumpswap_all_swaps
-- Returns: one row per day per venue
--
-- uniqExact is precise but heavy. Swap it for uniq() on wider ranges: the
-- approximation is close enough for trend work and much faster.
--
-- The UNION is wrapped in a subquery: ORDER BY applied directly to a UNION ALL
-- is resolved per branch, not over the combined result.

SELECT *
FROM
(
    SELECT 'pumpfun' AS venue,
           toDate(block_time)        AS day,
           uniqExact(signing_wallet) AS wallets,
           count()                   AS swaps
    FROM pumpfun_all_swaps
    WHERE block_time > now() - INTERVAL 14 DAY
    GROUP BY day

    UNION ALL

    SELECT 'pumpswap',
           toDate(block_time),
           uniqExact(signing_wallet),
           count()
    FROM pumpswap_all_swaps
    WHERE block_time > now() - INTERVAL 14 DAY
    GROUP BY toDate(block_time)
)
ORDER BY day, venue;
