-- Script to delete users
-- First, revoke all privileges from users to ensure clean removal
REVOKE ALL PRIVILEGES FROM "usr.adm.001";
REVOKE ALL PRIVILEGES FROM "usr.core.001";
REVOKE ALL PRIVILEGES FROM "usr.ro.001";

-- Revoke role memberships
REVOKE "app.admin.role" FROM "usr.adm.001";
REVOKE "app.core.role" FROM "usr.core.001";
REVOKE "app.ro.role" FROM "usr.ro.001";

-- Drop users
DROP USER IF EXISTS "usr.adm.001";
DROP USER IF EXISTS "usr.core.001";
DROP USER IF EXISTS "usr.ro.001";

-- Verify users are deleted
-- \du  -- List all users and their attributes