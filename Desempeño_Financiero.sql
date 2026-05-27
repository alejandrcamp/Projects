-- Explorar el esquema
SELECT *
FROM campanas
LIMIT 10;
SELECT *
FROM ventas_2017
LIMIT 10;
SELECT *
FROM territorios
LIMIT 10;
SELECT *
FROM productos
LIMIT 10;
SELECT *
FROM productos_categorias
LIMIT 10;

-- Extraer y limpiar datos
    -- Tratar valores faltants como nulos
SELECT
    v.numero_pedido,
    v.clave_producto,
    p.nombre_producto,
    pc.clave_categoria,
    COALESCE(p.precio_producto, 0)  AS precio_producto,
    COALESCE(v.cantidad_pedido, 0)  AS cantidad_pedido,
    COALESCE(p.costo_producto, 0)   AS costo_producto,
    t.pais,
    t.continente,
    v.clave_territorio,
    -- Crear dos columnas que nos digan dinero que entra y dinero que sale.
    COALESCE(p.precio_producto, 0) * COALESCE(v.cantidad_pedido, 0) AS ingreso_total,
    COALESCE(p.costo_producto, 0) * COALESCE(v.cantidad_pedido, 0) AS costo_total
    -- Unir tablas con columnas clave
FROM ventas_2017 AS v
JOIN productos AS p
  ON v.clave_producto = p.clave_producto
LEFT JOIN productos_categorias AS pc
  ON p.clave_subcategoria = pc.clave_subcategoria
LEFT JOIN territorios AS t
  ON v.clave_territorio = t.clave_territorio;

--Calcular ingresos y costos por país
SELECT
    p.pais,
    p.clave_territorio,
    SUM(p.ingresos)::integer AS ingresos,
    SUM(p.costos)::integer AS costos,
--Agregar la inversión en campañas de marketing
    COALESCE(SUM(c.costo_campana), 0)::integer AS costo_campana,
--Calcular Beneficio Bruto, Margen y ROI
    --Beneficio Bruto  (ganancia antes de marketing) 
    (SUM(p.ingresos)::integer - SUM(p.costos)::integer) AS beneficio_bruto,
    --Margen (eficiencia de ventas)
    (((SUM(p.ingresos)) - (SUM(p.costos)))*100) / SUM(p.ingresos) AS margen_pct ,
    --ROI (retorno sobre campañas)
    ((SUM(p.ingresos) - SUM(p.costos))*100) / NULLIF(SUM(c.costo_campana),0) AS roi_pct
FROM pais_ingreso_costo AS p
LEFT JOIN pais_campanas AS c
  ON p.clave_territorio = c.clave_territorio
GROUP BY
    p.pais,
    p.clave_territorio
ORDER BY
    p.clave_territorio, ingresos, costos;

-- Validar resultados
-- Conteo de Cantidades no válidas en ventas_2017 como productos_precio_no_valido
-- Usar < 0 para negativos
SELECT 
    COUNT(*) AS productos_precio_no_valido
FROM productos
WHERE precio_producto < 0
