SELECT 
    trip_id,
    load_id,
    driver_id,
    truck_id,
    dispatch_date,
    actual_distance_miles,
    actual_duration_hours,
    fuel_gallons_used,
    average_mpg
FROM {{ source('logistics_raw', 'trips') }}