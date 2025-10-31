# Create `study` schema and configure access

This document explains how to create the `study` schema inside the `study_db` database and configure access so:

- `usr.adm.001` — owns the schema and creates objects
- `app.core.role` / `usr.core.001` — can perform CRUD on objects in `study`
- `app.ro.role` / `usr.ro.001` — can perform SELECT only on objects in `study`

## Preconditions

- `study_db` database exists (see `create_database.sql`).
- Roles and users exist: `app.admin.role`, `app.core.role`, `app.ro.role` and users `usr.adm.001`, `usr.core.001`, `usr.ro.001`.
- You are connected to `study_db` as `usr.adm.001` (schema owner) when running the commands below.

## Commands (run as `usr.adm.001` connected to `study_db`)

1. Create the schema and set its owner
```sql
CREATE SCHEMA IF NOT EXISTS study AUTHORIZATION "usr.adm.001";
```

2. Grant schema USAGE to roles so they can access objects in the schema
```sql
GRANT USAGE ON SCHEMA study TO "app.core.role", "app.ro.role";
```

3. (Optional) Allow the core role to create objects in the schema
```sql
-- Only if your application requires core to create tables/functions
GRANT CREATE ON SCHEMA study TO "app.core.role";
```

4. Set default privileges for future objects created by `usr.adm.001` in schema `study`
```sql
-- Tables: core gets CRUD, ro gets SELECT
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
```

5. (Optional) Grant immediate privileges on existing objects in `study` (if you already imported schema/data)
```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA study TO "app.core.role";
GRANT SELECT ON ALL TABLES IN SCHEMA study TO "app.ro.role";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA study TO "app.core.role";
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA study TO "app.core.role";
```

## How to run (psql examples)

From PowerShell (connect as `usr.adm.001` and execute file):
```powershell
psql -U "usr.adm.001" -d study_db -f create_schema.sql
```

Run individual commands interactively:
```powershell
psql -U "usr.adm.001" -d study_db
# then inside psql
CREATE SCHEMA IF NOT EXISTS study AUTHORIZATION "usr.adm.001";
GRANT USAGE ON SCHEMA study TO "app.core.role", "app.ro.role";
... (other commands)
```

## Verification

1. Check schema owner
```sql
SELECT nspname, nspowner::regrole AS owner
FROM pg_namespace
WHERE nspname = 'study';
```

2. Check schema privileges
```sql
SELECT grantee, privilege_type
FROM information_schema.schema_privileges
WHERE schema_name = 'study';
```

3. Confirm default privileges for future objects (example for tables)
```sql
-- shows default privileges set by usr.adm.001 for schema 'study'
SELECT *
FROM pg_default_acl
WHERE defaclobjtype = 'r' -- r = table
  AND defaclnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'study');
```

4. Test as `usr.core.001` and `usr.ro.001` (practical test)

- As admin, create a test table and insert data:
```sql
-- run as usr.adm.001
CREATE TABLE study.test_table (id serial PRIMARY KEY, name text);
INSERT INTO study.test_table (name) VALUES ('alice'), ('bob');
```

- As core user, confirm CRUD works:
```sql
-- connect as usr.core.001
SELECT * FROM study.test_table;          -- should succeed
INSERT INTO study.test_table (name) VALUES ('carol'); -- should succeed if core has INSERT
UPDATE study.test_table SET name = 'eve' WHERE id = 1; -- should succeed
DELETE FROM study.test_table WHERE id = 2; -- should succeed
```

- As read-only user, confirm only SELECT works:
```sql
-- connect as usr.ro.001
SELECT * FROM study.test_table; -- should succeed
INSERT INTO study.test_table (name) VALUES ('x'); -- should fail
UPDATE study.test_table SET name = 'y' WHERE id = 1; -- should fail
DELETE FROM study.test_table WHERE id = 1; -- should fail
```

## Notes and caveats

- `ALTER DEFAULT PRIVILEGES` must be executed by the role that will create objects (or by the owner of those objects). If another role creates objects, run `ALTER DEFAULT PRIVILEGES FOR ROLE "that_role" ...` for that role.
- Collations/encodings and default privileges are independent of schema grants; make sure DB-level settings and schema-level grants are set correctly.
- If you grant `CREATE` to `app.core.role`, you may want to limit which object types or use additional governance to avoid uncontrolled schema changes.

## Troubleshooting

- If `usr.core.001` can't write, verify:
  - `usr.core.001` role membership (\du)
  - `INHERIT` is enabled for `usr.core.001` (so it inherits `app.core.role` privileges)
  - Default privileges were set by the role that creates objects

- If `usr.ro.001` can write, verify it hasn't been accidentally granted `app.core.role` or write privileges directly.

## Next steps

- Run the `create_schema.sql` script as `usr.adm.001` inside `study_db` then perform the test steps above.
- If you want, I can create a small test script `test_schema_access.sql` that runs the test table creation and exercises the users (requires interactive or credentialed psql runs).