-- =========================================================
-- PropTech360
-- Idempotent load validation
-- =========================================================

-- The actual parameterized UPSERT is performed by:
-- src/load_postgres.py
--
-- Grain:
-- one row per (property_id, month_date)
--
-- The loader uses:
--
-- INSERT ...
-- ON CONFLICT (property_id, month_date)
-- DO UPDATE ...

SELECT
    COUNT(*) AS total_fact_rows
FROM fact_property_month;


SELECT
    COUNT(*) AS total_rows,

    COUNT(
        DISTINCT (
            property_id,
            month_date
        )
    ) AS unique_property_months

FROM fact_property_month;


SELECT
    property_id,
    month_date,
    COUNT(*) AS duplicate_count

FROM fact_property_month

GROUP BY
    property_id,
    month_date

HAVING COUNT(*) > 1;
