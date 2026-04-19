CREATE OR REPLACE VIEW v_mascotas_vacunacion_pendiente AS
SELECT
    m.id AS mascota_id,
    m.nombre AS mascota,
    m.especie,
    d.nombre AS dueno,
    d.telefono,
    MAX(va.fecha_aplicacion) AS ultima_vacuna
FROM mascotas m
JOIN duenos d ON d.id = m.dueno_id
LEFT JOIN vacunas_aplicadas va ON va.mascota_id = m.id
WHERE m.activo = TRUE
GROUP BY m.id, m.nombre, m.especie, d.nombre, d.telefono
HAVING MAX(va.fecha_aplicacion) < CURRENT_DATE - INTERVAL '1 year'
    OR MAX(va.fecha_aplicacion) IS NULL;