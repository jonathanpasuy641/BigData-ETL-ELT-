-- 7.2 Top 15 municipios con mayor CANTIDAD de productos vendidos en Antioquia
SELECT municipio, SUM(cantidad) AS cantidad_total
FROM vista_operaciones
WHERE departamento = 'Antioquia'
GROUP BY municipio
ORDER BY cantidad_total DESC
LIMIT 15;
