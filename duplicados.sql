use pruebada;

-- saber si hay duplicados
SELECT codigo_company, COUNT(*) c
FROM TMP_LLENAR_CAMPOS
GROUP BY codigo_company
HAVING COUNT(*) > 1;

SELECT app_code, COUNT(*) c
FROM TMP_LLENAR_CAMPOS
GROUP BY app_code
HAVING COUNT(*) > 1;

SELECT app_code, `version`, COUNT(*) c
FROM TMP_LLENAR_CAMPOS
GROUP BY app_code, `version`
HAVING COUNT(*) > 1;

SELECT company_id, COUNT(*) c
FROM TMP_LLENAR_CAMPOS
GROUP BY company_id
HAVING COUNT(*) > 1;

-- Eliminamos si hay duplicados:
WITH cte AS (
  SELECT id_company, codigo_company,
         ROW_NUMBER() OVER (PARTITION BY codigo_company ORDER BY id_company) rn
  FROM TMP_LLENAR_CAMPOS
)
DELETE t
FROM TMP_LLENAR_CAMPOS t
JOIN cte ON t.id_company = cte.id_company
WHERE cte.rn > 1;
WITH cte AS (
  SELECT app_id, app_code,
         ROW_NUMBER() OVER (PARTITION BY app_code ORDER BY app_id) rn
  FROM TMP_LLENAR_CAMPOS
)
DELETE t
FROM TMP_LLENAR_CAMPOS t
JOIN cte ON t.app_id = cte.app_id
WHERE cte.rn > 1;
WITH cte AS (
  SELECT version_id, app_code, `version`,
         ROW_NUMBER() OVER (
           PARTITION BY app_code, `version`
           ORDER BY version_id
         ) rn
  FROM TMP_LLENAR_CAMPOS
)
DELETE t
FROM TMP_LLENAR_CAMPOS t
JOIN cte ON t.version_id = cte.version_id
WHERE cte.rn > 1;
WITH cte AS (
  SELECT version_company_id, company_id,
         ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY version_company_id) rn
  FROM TMP_LLENAR_CAMPOS
)
DELETE t
FROM TMP_LLENAR_CAMPOS t
JOIN cte ON t.version_company_id = cte.version_company_id
WHERE cte.rn > 1;


-- Antes de pasar los datos a las tablas finales, revisamos TMP_LLENAR_CAMPOS 
-- para quitar las filas que están repetidas. 
-- Dejamos solo la primera de cada grupo y borramos las demás, 
-- así nos aseguramos de no guardar información duplicada.