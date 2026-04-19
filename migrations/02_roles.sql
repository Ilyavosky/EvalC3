DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'rol_administrador') THEN CREATE ROLE rol_administrador; END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'rol_veterinario')   THEN CREATE ROLE rol_veterinario;   END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'rol_recepcionista') THEN CREATE ROLE rol_recepcionista; END IF;
END $$;

COMMENT ON ROLE rol_administrador IS 'CRUD completo sobre el sistema';
COMMENT ON ROLE rol_veterinario   IS 'Puede visualizar la información de las mascotas, agendar citas y aplicar vacunas';
COMMENT ON ROLE rol_recepcionista IS 'Solo puede agendar citas y ver la información de las mascotas';

GRANT CONNECT ON DATABASE clinica_vet TO rol_administrador, rol_veterinario, rol_recepcionista;
GRANT USAGE ON SCHEMA public TO rol_administrador, rol_veterinario, rol_recepcionista;