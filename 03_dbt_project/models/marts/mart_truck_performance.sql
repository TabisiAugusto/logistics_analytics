WITH trucks AS (
    SELECT * FROM {{ ref('stg_trucks') }}
),

trips AS (
    SELECT * FROM {{ ref('stg_trips') }}
),

trip_facts AS (
    SELECT * FROM {{ ref('fct_trip_profitability') }}
),

-- NUEVO: Traemos tu staging de mantenimiento
maintenance AS (
    SELECT * FROM {{ ref('stg_maintenance') }}
),

-- 1. Puente Financiero (Ingresos y Márgenes)
trip_truck_bridge AS (
    SELECT 
        tf.trip_id,
        tf.total_trip_revenue,
        tf.theoretical_gross_margin,
        tf.actual_distance_miles,
        t.truck_id 
    FROM trip_facts tf
    LEFT JOIN trips t ON tf.trip_id = t.trip_id
),

-- 2. Agregación Comercial: Lo que produce el camión
truck_commercial_metrics AS (
    SELECT 
        truck_id,
        COUNT(DISTINCT trip_id) as total_trips,
        SUM(actual_distance_miles) as total_miles_driven,
        SUM(total_trip_revenue) as total_revenue_generated,
        SUM(theoretical_gross_margin) as total_gross_margin_generated
    FROM trip_truck_bridge
    WHERE truck_id IS NOT NULL
    GROUP BY 1
),

-- 3. NUEVO - Agregación de Mantenimiento: Lo que gasta el camión en el taller
truck_maintenance_metrics AS (
    SELECT
        truck_id,
        COUNT(maintenance_id) as total_maintenance_events,
        SUM(maintenance_cost) as total_maintenance_cost
    FROM maintenance
    WHERE truck_id IS NOT NULL
    GROUP BY 1
)

-- 4. Modelo Final: Unimos la dimensión Camión con lo que produjo y lo que gastó
SELECT 
    t.truck_id,
    
    -- Atributos Físicos
    t.make,
    t.model_year,
    EXTRACT(YEAR FROM CURRENT_DATE()) - t.model_year as truck_age_years,
    t.fuel_type,
    t.truck_status,
    
    -- Métricas de Utilización
    COALESCE(tcm.total_trips, 0) as total_trips,
    COALESCE(tcm.total_miles_driven, 0) as total_miles_driven,
    
    -- Métricas Financieras Brutas (Lo que facturó)
    COALESCE(tcm.total_gross_margin_generated, 0) as total_gross_margin_generated,
    SAFE_DIVIDE(tcm.total_gross_margin_generated, tcm.total_miles_driven) as gross_margin_per_mile,
    
    -- Métricas de Taller (Lo que costó mantenerlo)
    COALESCE(tmm.total_maintenance_events, 0) as total_maintenance_events,
    COALESCE(tmm.total_maintenance_cost, 0) as total_maintenance_cost,
    SAFE_DIVIDE(tmm.total_maintenance_cost, tcm.total_miles_driven) as maintenance_cost_per_mile,
    
    -- EL KPI DEFINITIVO DEL DUEÑO: Margen Operativo Neto
    (COALESCE(tcm.total_gross_margin_generated, 0) - COALESCE(tmm.total_maintenance_cost, 0)) as net_operating_margin

FROM trucks t
LEFT JOIN truck_commercial_metrics tcm ON t.truck_id = tcm.truck_id
LEFT JOIN truck_maintenance_metrics tmm ON t.truck_id = tmm.truck_id
ORDER BY net_operating_margin DESC