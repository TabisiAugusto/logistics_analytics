SELECT 
    maintenance_id,
    truck_id,
    maintenance_date,
    maintenance_type,
    total_cost as maintenance_cost
FROM {{ source('logistics_raw', 'maintenance_records') }}