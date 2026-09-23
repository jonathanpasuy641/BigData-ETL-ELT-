-- 7.4 Los 5 municipios con MENOR monto de ventas, de menor a mayor
SELECT departamento, municipio, SUM(venta) AS monto_total
FROM vista_operaciones
GROUP BY departamento, municipio
ORDER BY monto_total ASC
LIMIT 5;
