-- Script to delete roles
-- First revoke all privileges from roles to ensure clean removal
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM "app.admin.role";
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM "app.admin.role";
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM "app.admin.role";

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM "app.core.role";
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM "app.core.role";
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM "app.core.role";

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM "app.ro.role";
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM "app.ro.role";
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM "app.ro.role";

-- Revoke schema usage
REVOKE USAGE ON SCHEMA public FROM "app.admin.role", "app.core.role", "app.ro.role";

-- Remove role hierarchy
REVOKE "app.core.role" FROM "app.admin.role";

-- Drop roles (in reverse order of dependency)
DROP ROLE IF EXISTS "app.ro.role";
DROP ROLE IF EXISTS "app.core.role";
DROP ROLE IF EXISTS "app.admin.role";

-- Verify roles are deleted
-- \du  -- List all roles and their attributes