-- =========================================================
-- PropTech360
-- PostgreSQL dimensional schema
-- =========================================================

CREATE TABLE IF NOT EXISTS dim_property (
    property_id VARCHAR(20) PRIMARY KEY,
    property_name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS dim_month (
    month_date DATE PRIMARY KEY,

    year_number INTEGER NOT NULL
        CHECK (year_number >= 2000),

    month_number INTEGER NOT NULL
        CHECK (month_number BETWEEN 1 AND 12),

    month_name VARCHAR(20) NOT NULL,

    quarter_number INTEGER NOT NULL
        CHECK (quarter_number BETWEEN 1 AND 4)
);

CREATE TABLE IF NOT EXISTS fact_property_month (

    property_id VARCHAR(20) NOT NULL,

    month_date DATE NOT NULL,

    total_units INTEGER NOT NULL
        CHECK (total_units >= 0),

    occupied_units INTEGER NOT NULL
        CHECK (occupied_units >= 0),

    occupancy_rate NUMERIC(10,6)
        CHECK (
            occupancy_rate IS NULL
            OR occupancy_rate BETWEEN 0 AND 1
        ),

    earned_monthly_rent_usd NUMERIC(14,2) NOT NULL
        CHECK (earned_monthly_rent_usd >= 0),

    resolved_orders INTEGER NOT NULL
        CHECK (resolved_orders >= 0),

    sla_eligible_orders INTEGER NOT NULL
        CHECK (sla_eligible_orders >= 0),

    sla_compliant_orders INTEGER NOT NULL
        CHECK (sla_compliant_orders >= 0),

    open_orders INTEGER NOT NULL
        CHECK (open_orders >= 0),

    sla_missing_response_orders INTEGER NOT NULL DEFAULT 0
        CHECK (sla_missing_response_orders >= 0),

    sla_compliance_rate NUMERIC(10,6)
        CHECK (
            sla_compliance_rate IS NULL
            OR sla_compliance_rate BETWEEN 0 AND 1
        ),

    energy_kwh NUMERIC(16,2) NOT NULL
        CHECK (energy_kwh >= 0),

    floor_area_sqm NUMERIC(16,2) NOT NULL
        CHECK (floor_area_sqm > 0),

    energy_intensity_kwh_sqm NUMERIC(16,6)
        CHECK (
            energy_intensity_kwh_sqm IS NULL
            OR energy_intensity_kwh_sqm >= 0
        ),

    created_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_fact_property_month
        PRIMARY KEY (
            property_id,
            month_date
        ),

    CONSTRAINT fk_fact_property
        FOREIGN KEY (property_id)
        REFERENCES dim_property(property_id),

    CONSTRAINT fk_fact_month
        FOREIGN KEY (month_date)
        REFERENCES dim_month(month_date),

    CONSTRAINT chk_occupied_not_above_total
        CHECK (
            occupied_units <= total_units
        ),

    CONSTRAINT chk_sla_not_above_eligible
        CHECK (
            sla_compliant_orders
            <= sla_eligible_orders
        )
);

CREATE INDEX IF NOT EXISTS idx_property_city
ON dim_property(city);

CREATE INDEX IF NOT EXISTS idx_fact_month
ON fact_property_month(month_date);

CREATE INDEX IF NOT EXISTS idx_fact_occupancy
ON fact_property_month(occupancy_rate);

CREATE INDEX IF NOT EXISTS idx_fact_energy_intensity
ON fact_property_month(
    energy_intensity_kwh_sqm
);
