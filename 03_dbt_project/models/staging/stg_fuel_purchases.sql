SELECT 
    fuel_purchase_id,
    trip_id,
    truck_id,
    driver_id,
    purchase_date,
    location_city,
    gallons,
    price_per_gallon,
    total_cost
FROM {{ source('logistics_raw', 'fuel_purchases') }}