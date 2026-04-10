SELECT 
    route_id,
    origin_city,
    destination_city,
    typical_distance_miles,
    base_rate_per_mile,
    fuel_surcharge_rate
FROM {{ source('logistics_raw', 'routes') }}