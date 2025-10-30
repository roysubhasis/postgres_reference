# Create `study_db` and grant access to application roles/users

This document explains how to create the `study_db` database and configure access for the application roles and users:

- `usr.adm.001` — administrative user (owner of the DB)
- `app.core.role` / `usr.core.001` — core application role/user (CRUD)
- `app.ro.role` / `usr.ro.001` — read-only role/user (SELECT only)

## Steps (safe, recommended order)

1. Ensure roles and users exist
   - Run `create_roles.sql` and `create_users.sql` first if not already executed.

2. Create the database (run as a superuser or any role that can CREATE DATABASE)

   Example (psql):

   psql -U postgres -f create_database.sql

   The top section of `create_database.sql` creates `study_db` and grants CONNECT to the application roles.

3. Connect to the new database as the administrative user (DB owner)

   Example (psql):

   psql -U "usr.adm.001" -d study_db

   Or from inside psql after creating the DB:

   \c study_db "usr.adm.001"

4. Inside `study_db`, run the default-privileges and schema grants

   The script `create_database.sql` includes commands that must be executed while connected to `study_db` as `usr.adm.001`:

   - `GRANT USAGE ON SCHEMA public TO "app.core.role", "app.ro.role";`
   - `ALTER DEFAULT PRIVILEGES FOR ROLE "usr.adm.001" IN SCHEMA public GRANT ...` (for tables, sequences, functions)

   These ensure that when `usr.adm.001` (or other object-creating accounts) creates tables, sequences, and functions,
   `app.core.role` will automatically receive CRUD/execute rights and `app.ro.role` will receive SELECT rights.

5. Verify access

   - From the core user (test CRUD):
     psql -U "usr.core.001" -d study_db
     then try: SELECT, INSERT, UPDATE, DELETE on a test table (create one as admin if needed)

   - From the read-only user (test SELECT):
     psql -U "usr.ro.001" -d study_db
     then try: SELECT on a test table; attempts to INSERT/UPDATE/DELETE should be denied

## Notes and recommendations

- Default privileges are set `FOR ROLE "usr.adm.001"`. If objects will be created by another role (for example `app.admin.role` directly), run the `ALTER DEFAULT PRIVILEGES FOR ROLE ...` commands for that role instead.
- The database owner's default privileges control what privileges are assigned automatically for objects they create. If your application creates objects under different roles, set default privileges for those roles as well.
- For existing objects (if you later import schema), run the `GRANT ... ON ALL TABLES/SEQUENCES/FUNCTIONS IN SCHEMA public` commands while connected to `study_db` to apply grants immediately.

## Locale and connection-limit details

- LC_COLLATE and LC_CTYPE

   - `LC_COLLATE` controls collation (sorting and comparison) rules for textual data. Setting
      `LC_COLLATE = 'en_GB.UTF-8'` makes string sorting and comparisons use UK English rules under UTF-8.
   - `LC_CTYPE` controls character classification (upper/lower, character classes). Setting
      `LC_CTYPE = 'en_GB.UTF-8'` keeps classification consistent with the chosen locale.
   - Important: both `LC_COLLATE` and `LC_CTYPE` are set at CREATE DATABASE time and cannot be changed
      for an existing database without dumping and restoring (pg_dump/pg_restore) or recreating the DB.
   - The locale must be installed/available on the host OS where PostgreSQL runs. On Linux check
      `locale -a` and on PostgreSQL you can inspect supported collations with `SELECT * FROM pg_collation`.

- CONNECTION LIMIT

   - `CONNECTION LIMIT` sets the maximum number of concurrent connections allowed to this database.
   - A value of `-1` means no per-database limit (i.e., unlimited from the database's perspective).
      This does not override the server-wide `max_connections` setting — the total connections still
      cannot exceed `max_connections`.
   - For production systems consider a finite per-database limit or use a connection pooler (PgBouncer)
      to avoid exhausting server resources.

- Syntax notes (`=` is optional)

   - PostgreSQL accepts option forms with or without `=`. For example these are equivalent:
      - `OWNER "usr.adm.001"` and `OWNER = "usr.adm.001"`
      - `ENCODING 'UTF8'` and `ENCODING = 'UTF8'`
   - Use the style that matches your team's conventions; both are valid SQL.


## Quick-run commands (example)

1) Create DB and grants in one-shot (superuser):

   psql -U postgres -f create_database.sql

2) Connect and run inner-section as admin (if not executed automatically):

   psql -U "usr.adm.001" -d study_db -c "GRANT USAGE ON SCHEMA public TO \"app.core.role\", \"app.ro.role\";"

   psql -U "usr.adm.001" -d study_db -c "ALTER DEFAULT PRIVILEGES FOR ROLE \"usr.adm.001\" IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO \"app.core.role\";"

   psql -U "usr.adm.001" -d study_db -c "ALTER DEFAULT PRIVILEGES FOR ROLE \"usr.adm.001\" IN SCHEMA public GRANT SELECT ON TABLES TO \"app.ro.role\";"

## Verification queries

- List databases:
  \l

- List roles and members:
  \du

- Check schema privileges (inside study_db):
  SELECT nspname, array_agg(privilege_type) FROM information_schema.role_table_grants WHERE table_schema = 'public' GROUP BY nspname;

### Exact verification snippets

Run these to confirm `datcollate`, `datctype` and connection limit for `study_db`.

-- 1) Database locale and per-database connection limit
```sql
SELECT datname, datcollate, datctype, datconnlimit
FROM pg_database
WHERE datname = 'study_db';
```

-- 2) Active connections (how many clients are currently connected to study_db)
```sql
SELECT COUNT(*) AS active_connections
FROM pg_stat_activity
WHERE datname = 'study_db';
```

-- 3) Server-wide maximum connections
```sql
SHOW max_connections;
```

You can run these directly from PowerShell (example):

```powershell
psql -U postgres -d postgres -c "SELECT datname, datcollate, datctype, datconnlimit FROM pg_database WHERE datname = 'study_db';"
psql -U postgres -d study_db -c "SELECT COUNT(*) AS active_connections FROM pg_stat_activity WHERE datname = 'study_db';"
psql -U postgres -d postgres -c "SHOW max_connections;"
```

If you need to change the per-database connection limit later, use:
```sql
ALTER DATABASE study_db WITH CONNECTION LIMIT = 100;
-- or to remove the per-database limit:
ALTER DATABASE study_db WITH CONNECTION LIMIT = -1;
```

## Troubleshooting

- If core user still cannot write: check role membership (\du), ensure `usr.core.001` has `INHERIT` and receives `app.core.role`, and verify default privileges were set by the owner who creates objects.
- If read-only user can write: verify it does NOT have `INHERIT` reversed or that the user hasn't been granted `app.core.role` accidentally.

## Next steps

- Create a small test table as `usr.adm.001` and test both users' access
- If your application creates objects under a different role, add `ALTER DEFAULT PRIVILEGES FOR ROLE "that_role" ...` as needed
