DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'rol_administrador') THEN CREATE ROLE rol_administrador; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'rol_veterinario') THEN CREATE ROLE rol_veterinario; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'rol_recepcionista') THEN CREATE ROLE rol_recepcionista; END IF;
END $$;

COMMENT ON ROLE rol_administrador   IS 'CRUD completo sobre el sistema';
COMMENT ON ROLE rol_veterinario IS 'Puede visualizar la información de las mascotas, agendar citas y aplicar vacunas';
COMMENT ON ROLE rol_recepcionista  IS 'Solo puede agendar citas y ver la información de las mascotas';

GRANT CONNECT ON DATABASE clinica_vet TO rol_administrador, rol_veterinario, rol_recepcionista;
GRANT USAGE ON SCHEMA public TO rol_administrador, rol_veterinario, rol_recepcionista;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO rol_administrador;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO rol_administrador;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO rol_administrador;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO rol_administrador;

GRANT SELECT ON mascotas, duenos, citas, veterinarios, vet_atiende_mascota TO rol_veterinario;
GRANT INSERT ON citas, vacunas_aplicadas TO rol_veterinario;
GRANT USAGE ON SEQUENCE citas_id_seq, vacunas_aplicadas_id_seq TO rol_veterinario;
GRANT SELECT ON vacunas_aplicadas, inventario_vacunas TO rol_veterinario;
GRANT EXECUTE ON PROCEDURE sp_agendar_cita(INT, INT, TIMESTAMP, TEXT) TO rol_veterinario;
GRANT EXECUTE ON FUNCTION fn_total_facturado(INT, INT) TO rol_veterinario;
GRANT SELECT ON v_mascotas_vacunacion_pendiente TO rol_veterinario;

GRANT SELECT ON mascotas, duenos, citas, veterinarios TO rol_recepcionista;
GRANT INSERT ON citas TO rol_recepcionista;
GRANT USAGE ON SEQUENCE citas_id_seq TO rol_recepcionista;
GRANT EXECUTE ON PROCEDURE sp_agendar_cita(INT, INT, TIMESTAMP, TEXT) TO rol_recepcionista;
GRANT SELECT ON v_mascotas_vacunacion_pendiente TO rol_recepcionista;