-- 7.1 Top 8 departamentos con mayor VOLUMEN de ventas (monto), de mayor a menor
SELECT departamento, SUM(venta) AS monto_total
FROM vista_operaciones
GROUP BY departamento
ORDER BY monto_total DESC
LIMIT 8;
