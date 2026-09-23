-- 7.6 Monto total de ventas de cada producto en Antioquia, de mayor a menor
SELECT producto, SUM(venta) AS monto_total
FROM vista_operaciones
WHERE departamento = 'Antioquia'
GROUP BY producto
ORDER BY monto_total DESC;
