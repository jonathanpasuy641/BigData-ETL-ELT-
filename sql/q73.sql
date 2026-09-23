-- 7.3 Top 5 departamentos con mayor cantidad de MANZALOCA vendida
SELECT departamento, SUM(cantidad) AS cantidad_total
FROM vista_operaciones
WHERE producto = 'MANZALOCA'
GROUP BY departamento
ORDER BY cantidad_total DESC
LIMIT 5;
