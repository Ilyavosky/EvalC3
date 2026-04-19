GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO rol_administrador;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO rol_administrador;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO rol_administrador;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO rol_administrador;

GRANT SELECT ON mascotas, duenos, citas, veterinarios, vet_atiende_mascota TO rol_veterinario;
GRANT INSERT ON citas, vacunas_aplicadas TO rol_veterinario;
GRANT USAGE ON SEQUENCE citas_id_seq, vacunas_aplicadas_id_seq TO rol_veterinario;
GRANT SELECT ON vacunas_aplicadas, inventario_vacunas TO rol_veterinario;
GRANT EXECUTE ON PROCEDURE sp_agendar_cita(INT, INT, TIMESTAMP, TEXT, INT) TO rol_veterinario;
GRANT EXECUTE ON PROCEDURE sp_registrar_mascota(VARCHAR, VARCHAR, DATE, INT, INT) TO rol_veterinario;
GRANT EXECUTE ON FUNCTION fn_total_facturado(INT, INT) TO rol_veterinario;
GRANT SELECT ON v_mascotas_vacunacion_pendiente TO rol_veterinario;

GRANT SELECT ON mascotas, duenos, citas, veterinarios TO rol_recepcionista;
GRANT INSERT ON citas, mascotas TO rol_recepcionista;
GRANT USAGE ON SEQUENCE citas_id_seq, mascotas_id_seq TO rol_recepcionista;
GRANT EXECUTE ON PROCEDURE sp_agendar_cita(INT, INT, TIMESTAMP, TEXT, INT) TO rol_recepcionista;
GRANT EXECUTE ON PROCEDURE sp_registrar_mascota(VARCHAR, VARCHAR, DATE, INT, INT) TO rol_recepcionista;
GRANT SELECT ON v_mascotas_vacunacion_pendiente TO rol_recepcionista;