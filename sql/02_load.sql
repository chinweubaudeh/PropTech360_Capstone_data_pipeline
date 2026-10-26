-- =========================================================
-- PropTech360
-- Topic 4 - Load / Idempotency Validation
-- =========================================================

-- The actual parameterized PostgreSQL loading is performed
-- in src/load_postgres.py using SQLAlchemy + psycopg.
--
-- The fact table grain is:
-- one row per (property_id, month_date)
--
-- The loader uses:
--
-- INSERT ...
-- ON CONFLICT (property_id, month_date)
-- DO UPDATE ...
--
-- This makes repeated pipeline runs idempotent.


-- ---------------------------------------------------------
-- 1. Check total rows
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_fact_rows
FROM fact_property_month;


-- ---------------------------------------------------------
-- 2. Verify property-month uniqueness
-- ---------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,

    COUNT(
        DISTINCT (
            property_id,
            month_date
        )
    ) AS unique_property_months

FROM fact_property_month;


-- ---------------------------------------------------------
-- 3. Detect duplicate property-month records
-- Expected result: zero rows
-- ---------------------------------------------------------

SELECT
    property_id,
    month_date,
    COUNT(*) AS duplicate_count

FROM fact_property_month

GROUP BY
    property_id,
    month_date

HAVING COUNT(*) > 1;


-- ---------------------------------------------------------
-- 4. Expected PropTech360 fact count
-- 12 properties x 6 months = 72
-- ---------------------------------------------------------

SELECT
    CASE
        WHEN COUNT(*) = 72
        THEN 'PASS'
        ELSE 'FAIL'
    END AS fact_row_count_test,

    COUNT(*) AS actual_fact_rows

FROM fact_property_month;
