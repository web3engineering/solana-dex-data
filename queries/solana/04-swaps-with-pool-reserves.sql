-- PumpSwap trades with pool state before and after each swap
--
-- Table:   pumpswap_all_swaps
-- Returns: individual swaps with the reserves that produced the price
--
-- This is the execution context most providers drop. With reserves on both
-- sides of the trade you can reconstruct the price impact of each fill
-- instead of inferring it.

SELECT
    block_time,
    signing_wallet,
    direction,
    base_token,
    base_token_amount,
    quote_token_amount,
    pool_base_token_reserves_before,
    pool_quote_token_reserves_before,
    pool_base_token_reserves_after,
    pool_quote_token_reserves_after,
    lp_fee,
    protocol_fee,
    coin_creator_fees
FROM pumpswap_all_swaps
WHERE block_time > now() - INTERVAL 1 HOUR
ORDER BY slot DESC, tx_idx DESC
LIMIT 20;

-- Note: each row is one swap instruction. A transaction routing through
-- several pools appears once per hop.
