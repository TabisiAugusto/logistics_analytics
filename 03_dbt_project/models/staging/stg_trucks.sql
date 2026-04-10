SELECT 
    truck_id,
    make,
    model_year,
    fuel_type,
    tank_capacity_gallons,
    status as truck_status
FROM {{ source('logistics_raw', 'trucks') }}