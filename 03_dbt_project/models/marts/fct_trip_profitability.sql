WITH trips AS (
    SELECT * FROM {{ ref('stg_trips') }}
),

loads AS (
    SELECT * FROM {{ ref('stg_loads') }}
),

routes AS (
    SELECT * FROM {{ ref('stg_routes') }}
),

fuel AS (
    SELECT 
        trip_id, 
        SUM(total_cost) as total_fuel_cost,
        SUM(gallons) as total_gallons_purchased
    FROM {{ ref('stg_fuel_purchases') }}
    GROUP BY 1
)

SELECT
    t.trip_id,
    t.dispatch_date,
    -- Información de Ruta
    r.origin_city,
    r.destination_city,
    r.typical_distance_miles,
    t.actual_distance_miles,
    
    -- Componentes de Ingresos
    l.revenue as base_revenue,
    l.fuel_surcharge,
    (l.revenue + l.fuel_surcharge) as total_trip_revenue,
    
    -- Componentes de Costos y Margen
    COALESCE(f.total_fuel_cost, 0) as fuel_cost_paid,
    (l.revenue + l.fuel_surcharge - COALESCE(f.total_fuel_cost, 0)) as gross_margin,
    
    -- KPIs de Desempeño Económico (Refactorizados)
    -- 1. Calculamos el costo operativo teórico (Consumo Real x Precio Promedio)
    (t.fuel_gallons_used * 3.50) as theoretical_fuel_cost,

    -- 2. Margen Bruto Teórico
    (l.revenue + l.fuel_surcharge - (t.fuel_gallons_used * 3.50)) as theoretical_gross_margin,

    -- 3. Margen por milla (usando el costo teórico)
    SAFE_DIVIDE(
        (l.revenue + l.fuel_surcharge - (t.fuel_gallons_used * 3.50)), 
        t.actual_distance_miles
    ) as theoretical_margin_per_mile,

    -- 4. Varianza de Distancia (Lo que ya tenías)
    (t.actual_distance_miles - r.typical_distance_miles) as distance_variance

FROM trips t
LEFT JOIN loads l ON t.load_id = l.load_id
LEFT JOIN routes r ON l.route_id = r.route_id
LEFT JOIN fuel f ON t.trip_id = f.trip_id