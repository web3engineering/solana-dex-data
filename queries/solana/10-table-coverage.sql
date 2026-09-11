-- How big each table is, and how far back it goes
--
-- Tables:  system.parts, then any data table
-- Returns: row count and size per table, plus a time range for one table
--
-- Run this first on a new connection. It shows what you actually have before
-- you write anything against it.

-- Size of every table in the database.
--
-- The output aliases deliberately avoid the names of the source columns: an
-- alias called rows would be resolved inside sum(rows) instead of the column.

SELECT
    table,
    formatReadableQuantity(sum(rows))      AS row_count,
    formatReadableSize(sum(bytes_on_disk)) AS disk_size
FROM system.parts
WHERE active
  AND database = currentDatabase()
GROUP BY table
ORDER BY sum(rows) DESC;


-- How far a single table goes back.
--
-- system.parts also exposes min_time and max_time, but those are only filled
-- in when the partition key carries a timestamp. These tables partition by
-- date, so those columns come back as the epoch default and mean nothing.
-- Read the range off the table itself instead.

SELECT
    toTimeZone(min(block_time), 'UTC') AS first_record_utc,
    toTimeZone(max(block_time), 'UTC') AS last_record_utc,
    count()                            AS rows_in_table
FROM pumpfun_token_creation;

-- Row counts, coverage and column descriptions for every table are also
-- published at https://onchaindivers.com/solana/tables
