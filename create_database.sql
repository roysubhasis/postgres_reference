-- Create database and set up access for application roles/users
-- Run the top part as a superuser or any role that can CREATE DATABASE.
-- Then connect to the new database as "usr.adm.001" (owner) and run the remaining commands.

-- 1) Create database owned by the administrative user
CREATE DATABASE study_db OWNER "usr.adm.001"
    ENCODING 'UTF8'
    LC_COLLATE = 'en_GB.UTF-8' -- optional
    LC_CTYPE = 'en_GB.UTF-8'   -- optional
    CONNECTION LIMIT = -1;

-- 2) Allow the application roles to connect to the database
GRANT CONNECT ON DATABASE study_db TO "app.core.role", "app.ro.role";

-- Note: The following commands must be executed while connected to study_db.
-- You can do that in psql with: \c study_db "usr.adm.001"

-- ---------------------------
-- Commands to run inside study_db (connect as "usr.adm.001")
-- ---------------------------

-- Grant schema usage so roles can access objects in the public schema
GRANT USAGE ON SCHEMA public TO "app.core.role", "app.ro.role";

-- If you want the users (instead of roles) to also be able to connect directly, grant CONNECT
-- (Usually granting to roles is enough if users inherit role privileges.)
GRANT CONNECT ON DATABASE study_db TO "usr.adm.001", "usr.core.001", "usr.ro.001";

-- Set default privileges so that any future tables/sequences/functions created by the
-- administrative user (or role) will automatically grant the appropriate rights.
-- These ALTER DEFAULT PRIVILEGES statements should be run as the role that will create objects
-- (commonly the DB owner or the admin user). Here we set them FOR ROLE "usr.adm.001".

-- Grant CRUD for core role on future tables
ALTER DEFAULT PRIVILEGES FOR ROLE "usr.adm.001" IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "app.core.role";

-- Grant SELECT only for read-only role on future tables
ALTER DEFAULT PRIVILEGES FOR ROLE "usr.adm.001" IN SCHEMA public
    GRANT SELECT ON TABLES TO "app.ro.role";

-- Sequences: core gets USAGE+SELECT, read-only gets SELECT
ALTER DEFAULT PRIVILEGES FOR ROLE "usr.adm.001" IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO "app.core.role";
ALTER DEFAULT PRIVILEGES FOR ROLE "usr.adm.001" IN SCHEMA public
    GRANT SELECT ON SEQUENCES TO "app.ro.role";

-- Functions: core role should be able to execute
ALTER DEFAULT PRIVILEGES FOR ROLE "usr.adm.001" IN SCHEMA public
    GRANT EXECUTE ON FUNCTIONS TO "app.core.role";

-- Optional: If there are existing objects you want to grant immediately (none in a new DB),
-- you would run these while connected to study_db:
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "app.core.role";
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO "app.ro.role";
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "app.core.role";
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO "app.core.role";

ALTER DATABASE study_db SET idle_in_transaction_session_timeout='0';

-- End of create_database.sql

-- ---------------------------
-- Verification queries (commented) - run these after creating the DB
-- ---------------------------
-- Show database locale and connection limit
-- SELECT datname, datcollate, datctype, datconnlimit FROM pg_database WHERE datname = 'study_db';

-- Show current active connections to the database
-- SELECT COUNT(*) AS active_connections FROM pg_stat_activity WHERE datname = 'study_db';

-- Show server-wide max connections
-- SHOW max_connections;

-- Example psql one-liners (PowerShell) to run the checks:
-- psql -U postgres -d postgres -c "SELECT datname, datcollate, datctype, datconnlimit FROM pg_database WHERE datname = 'study_db';"
-- psql -U postgres -d study_db -c "SELECT COUNT(*) AS active_connections FROM pg_stat_activity WHERE datname = 'study_db';"

