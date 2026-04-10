WITH drivers AS (
    SELECT * FROM {{ ref('stg_drivers') }}
),

trips AS (
    SELECT * FROM {{ ref('stg_trips') }}
),

trip_facts AS (
    SELECT * FROM {{ ref('fct_trip_profitability') }}
),

-- 1. Puente: Unimos los hechos financieros directamente con el ID del conductor
trip_driver_bridge AS (
    SELECT 
        tf.trip_id,
        tf.total_trip_revenue,
        tf.theoretical_gross_margin,
        tf.actual_distance_miles,
        tf.distance_variance,
        t.driver_id 
    FROM trip_facts tf
    LEFT JOIN trips t ON tf.trip_id = t.trip_id
),

-- 2. Agregación: Sumamos y promediamos todo a nivel de Conductor
driver_metrics AS (
    SELECT 
        driver_id,
        
        COUNT(DISTINCT trip_id) as total_trips,
        SUM(actual_distance_miles) as total_miles_driven,
        SUM(total_trip_revenue) as total_revenue_generated,
        SUM(theoretical_gross_margin) as total_gross_margin_generated,
        AVG(distance_variance) as avg_distance_variance
        
    FROM trip_driver_bridge
    WHERE driver_id IS NOT NULL
    GROUP BY 1
)

-- 3. Modelo Final: Unimos la dimensión Conductor con sus métricas calculadas
SELECT 
    dm.driver_id,
    
    -- Transformaciones de negocio con las columnas reales:
    CONCAT(d.first_name, ' ', d.last_name) as driver_name,
    DATE_DIFF(CURRENT_DATE(), d.hire_date, YEAR) as years_of_experience,
    
    -- Volumen
    COALESCE(dm.total_trips, 0) as total_trips,
    COALESCE(dm.total_miles_driven, 0) as total_miles_driven,
    
    -- Rentabilidad
    COALESCE(dm.total_revenue_generated, 0) as total_revenue_generated,
    COALESCE(dm.total_gross_margin_generated, 0) as total_gross_margin_generated,
    
    -- KPIs Clave
    SAFE_DIVIDE(dm.total_gross_margin_generated, dm.total_miles_driven) as avg_margin_per_mile,
    COALESCE(dm.avg_distance_variance, 0) as avg_distance_variance,
    
    -- Concentración
    SAFE_DIVIDE(
        dm.total_trips, 
        SUM(dm.total_trips) OVER()
    ) * 100 as share_of_total_trips_pct

FROM driver_metrics dm
LEFT JOIN drivers d ON dm.driver_id = d.driver_id
ORDER BY total_gross_margin_generated DESC