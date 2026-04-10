SELECT 
    load_id,
    customer_id,
    route_id,
    load_date,
    load_type,
    weight_lbs,
    revenue,
    fuel_surcharge
FROM {{ source('logistics_raw', 'loads') }}