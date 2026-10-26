-- =========================================================
-- PropTech360
-- Required analytical queries
-- =========================================================


-- =========================================================
-- 1. Property occupancy ranking
-- January-June 2026
-- =========================================================

SELECT
    f.property_id,
    p.property_name,
    p.city,

    SUM(f.occupied_units)
        AS occupied_unit_months,

    SUM(f.total_units)
        AS total_unit_months,

    ROUND(
        AVG(f.occupancy_rate),
        4
    ) AS average_monthly_occupancy_rate,

    RANK() OVER (
        ORDER BY AVG(f.occupancy_rate) DESC
    ) AS occupancy_rank

FROM fact_property_month f

JOIN dim_property p
    ON f.property_id = p.property_id

WHERE f.month_date
    BETWEEN DATE '2026-01-01'
    AND DATE '2026-06-30'

GROUP BY
    f.property_id,
    p.property_name,
    p.city

ORDER BY occupancy_rank;



-- =========================================================
-- 2. Monthly earned contractual rent by city
-- =========================================================

SELECT
    f.month_date,
    p.city,

    ROUND(
        SUM(f.earned_monthly_rent_usd),
        2
    ) AS earned_contractual_rent_usd

FROM fact_property_month f

JOIN dim_property p
    ON f.property_id = p.property_id

GROUP BY
    f.month_date,
    p.city

ORDER BY
    f.month_date,
    p.city;



-- =========================================================
-- 3. Maintenance SLA compliance by property
-- =========================================================

SELECT
    f.property_id,
    p.property_name,

    SUM(f.resolved_orders)
        AS resolved_orders,

    SUM(f.sla_eligible_orders)
        AS sla_eligible_resolved_orders,

    SUM(f.sla_compliant_orders)
        AS sla_compliant_orders,

    SUM(f.open_orders)
        AS excluded_unresolved_orders,

    SUM(f.sla_missing_response_orders)
        AS excluded_missing_response_orders,

    ROUND(
        SUM(f.sla_compliant_orders)::NUMERIC
        /
        NULLIF(
            SUM(f.sla_eligible_orders),
            0
        ),
        4
    ) AS sla_compliance_rate

FROM fact_property_month f

JOIN dim_property p
    ON f.property_id = p.property_id

GROUP BY
    f.property_id,
    p.property_name

ORDER BY
    sla_compliance_rate DESC NULLS LAST;



-- =========================================================
-- 4. Property-months above monthly portfolio
-- energy intensity
-- =========================================================

WITH portfolio_month AS (

    SELECT
        month_date,

        SUM(energy_kwh)
        /
        NULLIF(
            SUM(floor_area_sqm),
            0
        ) AS portfolio_energy_intensity

    FROM fact_property_month

    GROUP BY month_date
)

SELECT
    f.month_date,
    f.property_id,
    p.property_name,

    ROUND(
        f.energy_intensity_kwh_sqm,
        4
    ) AS property_energy_intensity,

    ROUND(
        pm.portfolio_energy_intensity,
        4
    ) AS portfolio_energy_intensity,

    ROUND(
        f.energy_kwh,
        2
    ) AS total_energy_kwh

FROM fact_property_month f

JOIN portfolio_month pm
    ON f.month_date = pm.month_date

JOIN dim_property p
    ON f.property_id = p.property_id

WHERE
    f.energy_intensity_kwh_sqm
    > pm.portfolio_energy_intensity

ORDER BY
    f.month_date,
    f.energy_intensity_kwh_sqm DESC;



-- =========================================================
-- 5. Portfolio dashboard view
-- =========================================================

CREATE OR REPLACE VIEW
vw_portfolio_dashboard AS

SELECT
    f.month_date,

    f.property_id,

    p.property_name,

    p.city,

    f.total_units,

    f.occupied_units,

    f.occupancy_rate,

    f.earned_monthly_rent_usd,

    f.resolved_orders,

    f.sla_eligible_orders,

    f.sla_compliant_orders,

    f.open_orders,

    f.sla_missing_response_orders,

    f.sla_compliance_rate,

    f.energy_kwh,

    f.floor_area_sqm,

    f.energy_intensity_kwh_sqm

FROM fact_property_month f

JOIN dim_property p
    ON f.property_id = p.property_id;


SELECT *
FROM vw_portfolio_dashboard
ORDER BY
    month_date,
    property_id;





