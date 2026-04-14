-- =============================================================================
-- PROYECTO: Logistics Data Pipeline & Analytics
-- ARCHIVO: 01_eda_exploration/queries_iniciales.sql
-- FUENTE ORIGINAL: Google Cloud Storage (Bucket: raw-data-logistics)
-- DESTINO: Google BigQuery (Dataset: logistics_raw)
-- OBJETIVO: Exploración Inicial (EDA) y Auditoría de Calidad de Datos
-- =============================================================================

/* 1. VALIDACIÓN DE CARGA INICIAL
   Objetivo: Verificar que los registros en BigQuery coinciden con la ingesta esperada 
   desde el Landing Zone (GCS).
*/
SELECT 'trips' AS tabla, COUNT(*) AS total_registros FROM `logistics_raw.trips`
UNION ALL
SELECT 'trucks', COUNT(*) FROM `logistics_raw.trucks`
UNION ALL
SELECT 'drivers', COUNT(*) FROM `logistics_raw.drivers`;


/* 2. AUDITORÍA DE VALORES NULOS (DATA QUALITY)
   Objetivo: Identificar la integridad de las columnas críticas. 
   Nota: Aquí se documenta el hallazgo de nulos en customer_name que motivó el uso de IDs en Looker Studio.
*/
SELECT 
    COUNT(*) AS total_viajes,
    -- Validación de Clientes
    COUNTIF(customer_id IS NULL) AS nulos_customer_id,
    COUNTIF(customer_name IS NULL OR customer_name = '') AS nulos_customer_name,
    -- Validación de Operaciones
    COUNTIF(truck_id IS NULL) AS nulos_truck_id,
    COUNTIF(driver_id IS NULL) AS nulos_driver_id
FROM `logistics_raw.trips`;


/* 3. PERFILADO DE LA FLOTA (METADATOS DE ACTIVOS)
   Objetivo: Analizar la distribución de antigüedad de los camiones antes de calcular rentabilidad.
*/
SELECT 
    MIN(model_year) AS anio_modelo_min,
    MAX(model_year) AS anio_modelo_max,
    AVG(2026 - model_year) AS promedio_antiguedad,
    COUNT(DISTINCT make) AS fabricantes_unicos
FROM `logistics_raw.trucks`;


/* 4. RANGOS Y OUTLIERS EN MÉTRICAS ECONÓMICAS
   Objetivo: Validar que los ingresos y pesos están en rangos operativos lógicos 
   para evitar sesgos en los promedios del dashboard.
*/
SELECT 
    -- Análisis de Carga
    MIN(avg_weight_lbs) AS peso_minimo,
    MAX(avg_weight_lbs) AS peso_maximo,
    AVG(avg_weight_lbs) AS peso_promedio,
    -- Análisis de Ingresos
    MIN(total_revenue) AS ingreso_min,
    MAX(total_revenue) AS ingreso_max,
    SUM(total_revenue) AS ingresos_totales_raw
FROM `logistics_raw.trips`;


/* 5. CONSISTENCIA TEMPORAL
   Objetivo: Confirmar el horizonte de tiempo de la data operativa.
*/
SELECT 
    MIN(trip_date) AS primera_operacion,
    MAX(trip_date) AS ultima_operacion,
    COUNT(DISTINCT trip_date) AS dias_con_actividad
FROM `logistics_raw.trips`;


/* 6. CHEQUEO DE UNICIDAD (PRIMARY KEYS)
   Objetivo: Asegurar que no existan duplicados que inflen los resultados de los KPIs.
*/
SELECT 
    truck_id, 
    COUNT(*) AS registros_duplicados
FROM `logistics_raw.trucks`
GROUP BY truck_id
HAVING registros_duplicados > 1;
