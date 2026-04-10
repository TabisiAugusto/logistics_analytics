SELECT 
    driver_id,
    first_name,
    last_name,
    hire_date
FROM {{ source('logistics_raw', 'drivers') }}