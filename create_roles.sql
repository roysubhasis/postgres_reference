-- Create Administrative Role
CREATE ROLE "app.admin.role" WITH 
    LOGIN
    NOSUPERUSER
    INHERIT
    CREATEDB
    CREATEROLE
    NOREPLICATION;

-- Create Core Application Role
CREATE ROLE "app.core.role" WITH 
    LOGIN
    NOSUPERUSER
    INHERIT
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION;

-- Create Read-Only Role
CREATE ROLE "app.ro.role" WITH 
    LOGIN
    NOSUPERUSER
    NOINHERIT  -- Explicitly prevent inheritance
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION;

-- Grant usage on public schema to all roles
GRANT USAGE ON SCHEMA public TO "app.admin.role", "app.core.role", "app.ro.role";

-- Set up permissions for administrative role (app.admin.role)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "app.admin.role";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "app.admin.role";
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO "app.admin.role";

-- Set up default privileges for future objects for admin role
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT ALL PRIVILEGES ON TABLES TO "app.admin.role";
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT ALL PRIVILEGES ON SEQUENCES TO "app.admin.role";
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT ALL PRIVILEGES ON FUNCTIONS TO "app.admin.role";

-- Set up permissions for core role (app.core.role)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "app.core.role";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO "app.core.role";
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO "app.core.role";

-- Set up default privileges for future objects for core role
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO "app.core.role";
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT USAGE, SELECT ON SEQUENCES TO "app.core.role";
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT EXECUTE ON FUNCTIONS TO "app.core.role";

-- Set up permissions for read-only role (app.ro.role)
-- First revoke all permissions to ensure clean state
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM "app.ro.role";
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM "app.ro.role";
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM "app.ro.role";

-- Grant only SELECT permissions to read-only role
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "app.ro.role";

-- Set up default privileges for future objects for read-only role
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT SELECT ON TABLES TO "app.ro.role";

-- Set up role hierarchy - Admin inherits Core permissions
GRANT "app.core.role" TO "app.admin.role";

-- Add comment to document the roles
COMMENT ON ROLE "app.admin.role" IS 'Administrative role with full privileges on public schema, can create DB and roles';
COMMENT ON ROLE "app.core.role" IS 'Core application role with CRUD operations, sequence usage, and function execution privileges';
COMMENT ON ROLE "app.ro.role" IS 'Read-only role with SELECT privileges only';

-- For security: You should set passwords for these roles in production
-- ALTER ROLE "app.admin.role" WITH PASSWORD 'your_secure_password';
-- ALTER ROLE "app.core.role" WITH PASSWORD 'your_secure_password';
-- ALTER ROLE "app.ro.role" WITH PASSWORD 'your_secure_password';
