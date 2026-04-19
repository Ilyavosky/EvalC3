CREATE OR REPLACE FUNCTION fn_registrar_historial_cita()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO historial_movimientos (tipo, referencia_id, descripcion)
    VALUES (
        'CITA_AGENDADA',
        NEW.id,
        'Cita agendada para mascota_id=' || NEW.mascota_id || ' con vet_id=' || NEW.veterinario_id
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_historial_cita
AFTER INSERT ON citas
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_historial_cita();

CREATE OR REPLACE FUNCTION fn_registrar_historial_mascota_alta()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO historial_movimientos (tipo, referencia_id, descripcion)
    VALUES (
        'MASCOTA_ALTA',
        NEW.id,
        'Mascota registrada: ' || NEW.nombre || ' (' || NEW.especie || ') dueno_id=' || NEW.dueno_id
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_historial_mascota_alta
AFTER INSERT ON mascotas
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_historial_mascota_alta();

CREATE OR REPLACE FUNCTION fn_registrar_historial_mascota_baja()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.activo = TRUE AND NEW.activo = FALSE THEN
        INSERT INTO historial_movimientos (tipo, referencia_id, descripcion)
        VALUES (
            'MASCOTA_BAJA',
            NEW.id,
            'Mascota dada de baja: ' || NEW.nombre || ' (id=' || NEW.id || ')'
        );
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_historial_mascota_baja
AFTER UPDATE ON mascotas
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_historial_mascota_baja();