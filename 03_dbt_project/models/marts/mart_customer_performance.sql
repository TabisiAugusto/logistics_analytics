WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

trip_facts AS (
    SELECT * FROM {{ ref('fct_trip_profitability') }}
),

trips AS (
    SELECT * FROM {{ ref('stg_trips') }}
),

loads AS (
    SELECT * FROM {{ ref('stg_loads') }}
),

-- 1. Puente: Unimos los hechos financieros con el ID del cliente y el peso de la carga
trip_customer_bridge AS (
    SELECT 
        tf.trip_id,
        tf.total_trip_revenue,
        tf.theoretical_gross_margin,
        tf.actual_distance_miles,
        tf.distance_variance,
        l.customer_id,
        l.weight_lbs
    FROM trip_facts tf
    LEFT JOIN trips t ON tf.trip_id = t.trip_id
    LEFT JOIN loads l ON t.load_id = l.load_id
),

-- 2. Agregación: Sumamos y promediamos todo a nivel de Cliente
customer_metrics AS (
    SELECT 
        customer_id,
        
        -- Bloque 1: Volumen Comercial
        COUNT(DISTINCT trip_id) as total_trips,
        SUM(total_trip_revenue) as total_revenue,
        
        -- Bloque 2: Rentabilidad Real
        SUM(theoretical_gross_margin) as total_gross_margin,
        SUM(actual_distance_miles) as total_miles,
        
        -- Bloque 3: Perfil Operativo
        AVG(weight_lbs) as avg_weight_lbs,
        AVG(distance_variance) as avg_distance_variance
        
    FROM trip_customer_bridge
    WHERE customer_id IS NOT NULL
    GROUP BY 1
)

-- 3. Modelo Final: Unimos la dimensión Cliente con sus métricas calculadas
SELECT 
    cm.customer_id, -- Usamos el de la tabla de métricas para que no venga nulo
    c.customer_name,
    c.customer_type,
    c.account_status,
    
    -- Métricas Comerciales
    COALESCE(cm.total_trips, 0) as total_trips,
    COALESCE(cm.total_revenue, 0) as total_revenue,
    SAFE_DIVIDE(cm.total_revenue, cm.total_trips) as avg_revenue_per_trip,
    
    -- Métricas de Rentabilidad
    COALESCE(cm.total_gross_margin, 0) as total_gross_margin,
    SAFE_DIVIDE(cm.total_gross_margin, cm.total_revenue) * 100 as margin_percentage,
    SAFE_DIVIDE(cm.total_gross_margin, cm.total_miles) as avg_margin_per_mile,
    
    -- Métricas Operativas
    COALESCE(cm.avg_weight_lbs, 0) as avg_weight_lbs,
    COALESCE(cm.avg_distance_variance, 0) as avg_distance_variance, -- <--- AQUÍ ESTABA EL ERROR (FALTABA LA COMA)

    -- Métrica de Riesgo/Participación
    SAFE_DIVIDE(
        cm.total_trips, 
        SUM(cm.total_trips) OVER()
    ) * 100 as share_of_total_trips_pct

FROM customer_metrics cm
LEFT JOIN customers c ON cm.customer_id = c.customer_id
ORDER BY total_gross_margin DESC