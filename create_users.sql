-- Create users with their respective roles
-- Note: Replace 'your_secure_password' with actual secure passwords in production

-- Create administrative user
CREATE USER "usr.adm.001" WITH 
    PASSWORD 'your_secure_password'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    INHERIT
    LOGIN;

-- Create core application user
CREATE USER "usr.core.001" WITH 
    PASSWORD 'your_secure_password'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    INHERIT
    LOGIN;

-- Create read-only user
CREATE USER "usr.ro.001" WITH 
    PASSWORD 'your_secure_password'
    NOSUPERUSER
    NOCREATEDB
    NOCREATEROLE
    INHERIT
    LOGIN;

-- Grant roles to respective users
GRANT "app.admin.role" TO "usr.adm.001";
GRANT "app.core.role" TO "usr.core.001";
GRANT "app.ro.role" TO "usr.ro.001";

-- Add comments to document the users
COMMENT ON ROLE "usr.adm.001" IS 'Administrative user with app.admin.role privileges';
COMMENT ON ROLE "usr.core.001" IS 'Core application user with app.core.role privileges';
COMMENT ON ROLE "usr.ro.001" IS 'Read-only user with app.ro.role privileges';

-- To verify user creation and role assignments, you can run:
-- \du  -- Lists all users and their role memberships