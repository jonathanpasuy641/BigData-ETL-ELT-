-- 7.5 Cantidad de gaseosas vendidas por producto y por región, de mayor a menor
SELECT r.nombre AS region, vo.producto, SUM(vo.cantidad) AS cantidad_total
FROM vista_operaciones vo
JOIN operaciones op ON op.id_registro = vo.id_registro
JOIN regiones r ON r.id_region = op.id_region
GROUP BY r.nombre, vo.producto
ORDER BY cantidad_total DESC;
