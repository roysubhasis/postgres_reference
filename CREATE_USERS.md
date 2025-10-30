# PostgreSQL Users Configuration Guide

This document explains the PostgreSQL users and their role assignments defined in `create_users.sql`.

## User Overview

The configuration creates three distinct users with different role assignments:

### 1. Administrative User (`usr.adm.001`)

**Configuration:**
- Login enabled
- Not a superuser
- Inherits privileges
- Cannot directly create databases (uses role privileges)
- Cannot directly create roles (uses role privileges)
- Password protected

**Assigned Role:**
- `app.admin.role`
  - Full privileges on public schema
  - Can create databases and roles through role privileges
  - Inherits core application permissions

### 2. Core Application User (`usr.core.001`)

**Configuration:**
- Login enabled
- Not a superuser
- Inherits privileges
- Cannot create databases
- Cannot create roles
- Password protected

**Assigned Role:**
- `app.core.role`
  - CRUD operations on tables
  - Usage and select on sequences
  - Execute on functions
  - Schema usage rights

### 3. Read-Only User (`usr.ro.001`)

**Configuration:**
- Login enabled
- Not a superuser
- Inherits privileges
- Cannot create databases
- Cannot create roles
- Password protected

**Assigned Role:**
- `app.ro.role`
  - SELECT only privileges
  - No write access
  - Schema usage rights

## Security Configuration

### Password Management
```sql
-- Set secure passwords for users (example)
ALTER USER "usr.adm.001" WITH PASSWORD 'your_secure_password';
ALTER USER "usr.core.001" WITH PASSWORD 'your_secure_password';
ALTER USER "usr.ro.001" WITH PASSWORD 'your_secure_password';
```

### Verification Commands
```sql
-- List all users and their role assignments
\du

-- Check specific user's role memberships
\du usr.adm.001
\du usr.core.001
\du usr.ro.001
```

## Implementation Steps

1. **Prerequisites**
   - Ensure `create_roles.sql` has been executed
   - Verify roles exist and are properly configured

2. **User Creation**
   - Execute `create_users.sql`
   - Set secure passwords for all users
   - Verify user creation and role assignments

3. **Post-Creation Steps**
   - Change default passwords
   - Test access levels for each user
   - Document passwords securely

## Best Practices

1. **Password Security**
   - Use strong, unique passwords
   - Change passwords regularly
   - Never share passwords
   - Use password management system in production

2. **Access Control**
   - Regularly audit user permissions
   - Remove unused accounts promptly
   - Monitor login attempts
   - Use SSL for connections

3. **User Management**
   - Document all user creations
   - Regular permission reviews
   - Maintain user-role mapping documentation
   - Implement password rotation policy

## Usage Examples

### Administrative User
```sql
-- Connect as admin user
psql -U usr.adm.001 -d your_database

-- This user can perform all CRUD operations plus:
CREATE DATABASE new_database;
CREATE ROLE new_role;
```

### Core Application User
```sql
-- Connect as core user
psql -U usr.core.001 -d your_database

-- This user can perform CRUD operations:
SELECT * FROM table;
INSERT INTO table VALUES (...);
UPDATE table SET ...;
DELETE FROM table WHERE ...;
```

### Read-Only User
```sql
-- Connect as read-only user
psql -U usr.ro.001 -d your_database

-- This user can only perform SELECT operations:
SELECT * FROM table;
```

## Security Notes

1. **Access Restrictions**
   - Users inherit only intended permissions
   - Read-only user cannot modify data
   - Core user cannot create databases/roles
   - Admin user has full control through role

2. **Monitoring**
   - Regular access audits
   - Monitor failed login attempts
   - Review user activity logs
   - Check role membership changes

3. **Maintenance**
   - Regular permission reviews
   - Update passwords periodically
   - Remove/disable inactive users
   - Keep documentation updated