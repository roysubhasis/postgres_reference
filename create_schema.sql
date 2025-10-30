-- Create schema `study` and configure access
-- Run this while connected to `study_db` as the administrative user "usr.adm.001".

-- 1) Create schema owned by the admin user
CREATE SCHEMA IF NOT EXISTS study AUTHORIZATION "usr.adm.001";

-- 2) Grant schema usage so roles can access objects in the schema
GRANT USAGE ON SCHEMA study TO "app.core.role", "app.ro.role";

-- Note: We do NOT grant CREATE to core/ro roles by default. If your application requires
-- the core role to create objects in this schema, grant CREATE to "app.core.role" explicitly.
-- Example: GRANT CREATE ON SCHEMA study TO "app.core.role";

-- 3) Default privileges for future objects created by the admin user in schema `study`.
-- Run these as the role that will create objects (here: "usr.adm.001").

-- Tables: core gets CRUD, ro gets SELECT only
ALTER DEFAULT PRIVILEGES FOR ROLE "usr.adm.001" IN SCHEMA study
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "app.core.role";
ALTER DEFAULT PRIVILEGES FOR ROLE "usr.adm.001" IN SCHEMA study
    GRANT SELECT ON TABLES TO "app.ro.role";

-- Sequences: core gets USAGE+SELECT, ro gets SELECT
ALTER DEFAULT PRIVILEGES FOR ROLE "usr.adm.001" IN SCHEMA study
    GRANT USAGE, SELECT ON SEQUENCES TO "app.core.role";
ALTER DEFAULT PRIVILEGES FOR ROLE "usr.adm.001" IN SCHEMA study
    GRANT SELECT ON SEQUENCES TO "app.ro.role";

-- Functions: core role should be able to execute
ALTER DEFAULT PRIVILEGES FOR ROLE "usr.adm.001" IN SCHEMA study
    GRANT EXECUTE ON FUNCTIONS TO "app.core.role";

-- 4) Optional immediate grants for existing objects (uncomment if needed)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA study TO "app.core.role";
-- GRANT SELECT ON ALL TABLES IN SCHEMA study TO "app.ro.role";
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA study TO "app.core.role";
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA study TO "app.core.role";

-- Verification queries (run as any superuser or db owner):
-- SELECT nspname, nspowner::regrole FROM pg_namespace WHERE nspname = 'study';
-- SELECT grantee, privilege_type FROM information_schema.schema_privileges WHERE schema_name = 'study';

-- End of create_schema.sql
