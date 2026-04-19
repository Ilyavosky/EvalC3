ALTER TABLE mascotas ADD COLUMN IF NOT EXISTS activo BOOLEAN DEFAULT TRUE;

CREATE OR REPLACE PROCEDURE sp_registrar_mascota(
    p_nombre VARCHAR(50),
    p_especie VARCHAR(30),
    p_fecha_nacimiento DATE,
    p_dueno_id INT,
    OUT p_mascota_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM duenos WHERE id = p_dueno_id) THEN
        RAISE EXCEPTION 'Dueño % no existe', p_dueno_id;
    END IF;

    INSERT INTO mascotas (nombre, especie, fecha_nacimiento, dueno_id, activo)
    VALUES (p_nombre, p_especie, p_fecha_nacimiento, p_dueno_id, TRUE)
    RETURNING id INTO p_mascota_id;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_dar_baja_mascota(
    p_mascota_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM mascotas WHERE id = p_mascota_id) THEN
        RAISE EXCEPTION 'Mascota % no existe', p_mascota_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM mascotas WHERE id = p_mascota_id AND activo = TRUE) THEN
        RAISE EXCEPTION 'Mascota % ya está dada de baja', p_mascota_id;
    END IF;

    UPDATE mascotas SET activo = FALSE WHERE id = p_mascota_id;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_agendar_cita(
    p_mascota_id INT,
    p_veterinario_id INT,
    p_fecha_hora TIMESTAMP,
    p_motivo TEXT,
    OUT p_cita_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM mascotas WHERE id = p_mascota_id) THEN
        RAISE EXCEPTION 'Mascota % no existe', p_mascota_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM veterinarios WHERE id = p_veterinario_id AND activo = TRUE) THEN
        RAISE EXCEPTION 'Veterinario % no existe o está inactivo', p_veterinario_id;
    END IF;

    INSERT INTO citas (mascota_id, veterinario_id, fecha_hora, motivo, estado)
    VALUES (p_mascota_id, p_veterinario_id, p_fecha_hora, p_motivo, 'AGENDADA')
    RETURNING id INTO p_cita_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_total_facturado(
    p_mascota_id INT,
    p_anio INT
) RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(costo), 0)
    INTO v_total
    FROM citas
    WHERE mascota_id = p_mascota_id
      AND EXTRACT(YEAR FROM fecha_hora) = p_anio
      AND estado = 'COMPLETADA';

    RETURN v_total;
END;
$$;