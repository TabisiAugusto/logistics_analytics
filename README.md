# Logistics Data Pipeline & Analytics

## 🎯 Objetivo del Proyecto
Diseño y ejecución de un pipeline de datos moderno para una empresa de logística. El proyecto transforma datos operativos crudos en indicadores estratégicos para optimizar la rentabilidad de la flota, medir la eficiencia de los conductores y analizar la concentración de ingresos por clientes.

## 🛠️ Stack Tecnológico
- **Google BigQuery:** Data Warehouse en la nube para el almacenamiento y procesamiento de datos.
- **dbt (data build tool):** Orquestación y transformación de datos mediante SQL modular (Capas de Staging y Marts).
- **Looker Studio:** Dashboards interactivos para la visualización de Business Intelligence.
- **GitHub:** Control de versiones y gestión de seguridad del código.

## 📂 Estructura del Repositorio
- **02_documentation/:** Documentación detallada sobre el modelado de datos y reglas de negocio.
- **03_dbt_project/:** Código fuente de dbt:
    1. **Staging:** Limpieza y normalización de las tablas de origen.
    2. **Marts:** Modelos finales de negocio (`truck_performance`, `driver_performance`).

## ⚙️ Proceso de Ingeniería de Datos
- **Ingesta:** Carga de datos crudos directamente a un bucket en BigQuery.
- **Transformación:** Normalización y creación de modelos dimensionales en dbt para facilitar la explotación.
- **Seguridad:** Identificación y remediación de filtración de credenciales (Service Account), revocación de accesos en Google Cloud Console y limpieza de historial en Git para asegurar el entorno.

## 📊 Métricas Clave Definidas
El valor del proyecto radica en KPIs económicos y operativos precisos:
- **Financieras:** Total Revenue, Total Gross Profit, Gross Margin, Ganancia Promedio por Viaje.
- **Eficiencia:** Avg Margin per Mile (Media de flota: $3.58), Margen Operativo Neto.
- **Flota:** Costo Total Mantenimiento, Costo Mantenimiento por Milla, Antigüedad del Camión.
- **Operativas:** Total Millas Viajadas, Promedio de Peso en Libras, Años de Experiencia del Conductor.

## 📈 Visualización y Business Insights
El reporte en Looker Studio se divide en tres áreas estratégicas:

### 1. Rendimiento de Flota
- **Análisis de Rentabilidad:** Uso de gráficos de dispersión para comparar el Margen Operativo Neto vs. la antigüedad del camión, incluyendo una línea de **Breakeven** para identificar unidades con rendimiento negativo.
- **Ranking de Costos Críticos:** Tabla de control que destaca unidades con alto **Costo de Mantenimiento por Milla** (ej. International 2015 con $0.06/milla), permitiendo priorizar renovaciones.
- **Distribución:** Desglose de la flota por fabricante (PACCAR y Navistar como líderes de volumen).

### 2. Desempeño de Conductores
- **Ranking de Eficiencia:** Comparativa de conductores frente al **Margen Promedio por Milla** de la flota para identificar los perfiles más rentables.
- **Volumen vs. Rentabilidad:** Análisis de la relación entre millas conducidas y ganancia bruta generada.
- **Curva de Aprendizaje:** El gráfico combinado confirma que los conductores con mayores **años de experiencia** generan una ganancia bruta total superior.

### 3. Análisis de Clientes
- **Concentración (Top 10):** Identificación de los clientes principales que sostienen el volumen de ingresos, con líneas de referencia para comparar la ganancia promedio.
- **Relación Peso vs. Ingreso:** Análisis del peso promedio de carga (`avg_weight_lbs`) frente al ingreso por viaje para detectar si el peso de la mercancía está correctamente tarifado o si existen ineficiencias comerciales.

## 💡 Conclusiones de Negocio
Este pipeline permite a la gerencia pasar de una gestión reactiva a una basada en datos. Mediante el monitoreo del **margen neto por milla** y el control de **costos de mantenimiento críticos**, la empresa puede identificar qué activos y recursos humanos están optimizando la rentabilidad y cuáles requieren intervención inmediata para mejorar el margen operativo neto.
