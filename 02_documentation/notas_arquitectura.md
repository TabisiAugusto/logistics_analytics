# Notas de Arquitectura: Pipeline de Analítica Logística

Este documento describe la infraestructura técnica, las transformaciones de datos y los criterios de negocio aplicados para convertir datos operativos crudos en un sistema de soporte de decisiones.

---

## 1. Arquitectura del Pipeline (ELT)
El proyecto utiliza un flujo de datos moderno basado en la nube:

* **Almacenamiento (Ingesta)**: Los datos se cargaron directamente a un bucket en **Google BigQuery** para su procesamiento centralizado.
* **Transformación (dbt)**: Se utilizó dbt para modularizar el SQL en capas lógicas:
    * **Staging**: Capa de limpieza inicial, renombre de campos y tipado de datos.
    * **Marts**: Generación de tablas finales agregadas y listas para el consumo de negocio.
* **Visualización**: **Looker Studio** conectado a los modelos de dbt para asegurar una "única fuente de verdad".

---

## 2. Modelado de Datos (dbt Marts)
El core de la inteligencia del proyecto reside en dos modelos principales:

### `mart_truck_performance`
Cruza información de viajes y camiones para determinar la rentabilidad del activo.
* **Granularidad**: Un registro por camión (`truck_id`).
* **Lógica Clave**: Unión de ingresos por viajes con el historial de costos de mantenimiento para calcular el margen operativo real.

### `mart_driver_performance`
Analiza la productividad de la fuerza laboral cruzando distancia, rentabilidad y experiencia.
* **Granularidad**: Un registro por conductor (`driver_name`).
* **KPI Principal**: `avg_margin_per_mile` para evaluar el rendimiento sin sesgos de distancia.

---

## 3. Diccionario de Reglas de Negocio
Se aplicaron las siguientes transformaciones lógicas en SQL para generar los KPIs visualizados:

| KPI | Fórmula / Lógica |
| :--- | :--- |
| **Antigüedad (Truck Age)** | `2026 - model_year` (Define el eje X en el análisis de flota). |
| **Net Operating Margin** | `total_gross_profit - total_maintenance_cost`. |
| **Avg Margin per Mile** | `total_gross_profit / total_miles_driven` (Media actual de flota: $3.58). |
| **Costo Mantenimiento por Milla** | `total_maintenance_cost / total_miles_driven` (Indicador de eficiencia técnica). |

---

## 4. Estrategia de Visualización (Business Intelligence)
Cada tablero fue diseñado para responder a preguntas críticas de operación:

* **Flota**: Se implementó una **línea de Breakeven** en gráficos de dispersión para separar visualmente los activos rentables de aquellos que generan pérdida neta.
* **Conductores**: Se integró una comparativa de **Años de Experiencia contra Margen Bruto** para validar el impacto de la veteranía en la rentabilidad.
* **Clientes**: Se utilizó el análisis de **Peso Promedio (avg_weight_lbs) vs. Ingreso por Viaje** para detectar clientes con fletes pesados sub-tarifados.

---

## 5. Gestión de Seguridad y Versiones
* **Remediación de Seguridad**: Se realizó la revocación de Service Accounts tras detectar una exposición de claves JSON en el historial de Git.
* **Control de Versiones**: Uso de ramas en GitHub para separar el desarrollo de la configuración inicial (`setup-inicial`) de la producción (`main`).
* **Buenas Prácticas**: Implementación de archivos `.gitignore` para proteger credenciales y archivos de configuración sensibles (`profiles.yml`).
