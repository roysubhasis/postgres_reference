-- Script to revoke or alter user roles

-- 1. Revoke a specific role from a user
REVOKE "app.admin.role" FROM "usr.adm.001";
REVOKE "app.core.role" FROM "usr.core.001";
REVOKE "app.ro.role" FROM "usr.ro.001";

-- 2. Assign a different role to a user
-- For example, demote an admin user to core user
REVOKE "app.admin.role" FROM "usr.adm.001";
GRANT "app.core.role" TO "usr.adm.001";

-- 3. Promote a core user to admin
REVOKE "app.core.role" FROM "usr.core.001";
GRANT "app.admin.role" TO "usr.core.001";

-- 4. Restrict a core user to read-only
REVOKE "app.core.role" FROM "usr.core.001";
GRANT "app.ro.role" TO "usr.core.001";

-- 5. Revoke all privileges from a specific user
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM "usr.adm.001";
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM "usr.adm.001";
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM "usr.adm.001";

-- 6. Disable a user's login privilege
ALTER USER "usr.adm.001" WITH NOLOGIN;

-- 7. Re-enable a user's login privilege
ALTER USER "usr.adm.001" WITH LOGIN;

-- 8. Change user attributes
ALTER USER "usr.adm.001" WITH 
    NOINHERIT  -- Disable privilege inheritance
    NOCREATEDB  -- Remove database creation privilege
    NOCREATEROLE;  -- Remove role creation privilege

-- 9. Reset user password
ALTER USER "usr.adm.001" WITH PASSWORD 'new_secure_password';

-- Verification queries
-- Check user roles and attributes
-- \du "usr.adm.001"
-- \du "usr.core.001"
-- \du "usr.ro.001"

-- Note: Always ensure to:
-- 1. Backup before making role changes
-- 2. Test access after changes
-- 3. Document all role modifications
-- 4. Verify permissions after changes