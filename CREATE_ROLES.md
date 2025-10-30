# PostgreSQL Role Configuration Guide

This document explains the PostgreSQL roles and permissions defined in `create_roles.sql`.

## Role Overview

The configuration establishes three distinct roles with different privilege levels:

### 1. Administrative Role (`app.admin.role`)

**Capabilities:**
- Login access
- Database creation
- Role creation
- Not a superuser
- Inherits role privileges
- No replication capabilities

**Privileges:**
- Full privileges (ALL) on:
  - All tables in public schema
  - All sequences in public schema
  - All functions in public schema
- Inherits all permissions from core role

### 2. Core Application Role (`app.core.role`)

**Capabilities:**
- Login access
- Inherits role privileges
- Cannot create databases
- Cannot create roles
- Not a superuser
- No replication capabilities

**Privileges:**
- USAGE on public schema
- CRUD operations (SELECT, INSERT, UPDATE, DELETE) on all tables
- USAGE and SELECT on sequences
- EXECUTE on all functions

### 3. Read-Only Role (`app.ro.role`)

**Capabilities:**
- Login access
- Does not inherit privileges (NOINHERIT)
- Cannot create databases
- Cannot create roles
- Not a superuser
- No replication capabilities

**Privileges:**
- USAGE on public schema
- SELECT privilege on all tables
- No write access to any objects

## Default Privileges for Future Objects

The configuration automatically sets privileges for newly created objects:

### For `app.admin.role`:
- ALL privileges on new tables
- ALL privileges on new sequences
- ALL privileges on new functions

### For `app.core.role`:
- CRUD operations on new tables
- USAGE and SELECT on new sequences
- EXECUTE on new functions

### For `app.ro.role`:
- SELECT privilege on new tables only

## Role Hierarchy

The roles are organized in a hierarchical structure:
- `app.admin.role` inherits from `app.core.role`
- `app.core.role` has its own set of permissions
- `app.ro.role` is standalone with no inheritance

## Security Features

1. **Password Protection**
   - All roles require passwords (must be set before use)
   - Default passwords should be changed upon first use

2. **Explicit Privilege Grants**
   - All privileges are explicitly defined
   - Revocation of permissions before granting new ones
   - No implicit permissions

3. **Role Documentation**
   - Each role includes descriptive comments
   - Clear purpose definition for each role

## Best Practices Implemented

1. **Principle of Least Privilege**
   - Each role has only the permissions it needs
   - Hierarchical privilege structure
   - Read-only role explicitly prevents inheritance

2. **Role-Based Access Control (RBAC)**
   - Clear separation of responsibilities
   - Three distinct access levels:
     - Administrative
     - Application
     - Read-only

3. **Future-Proofing**
   - Default privileges ensure consistent permissions on new objects
   - Maintains security model as database grows

## Usage

To implement these roles:

1. Connect to PostgreSQL instance as a superuser(postgres)
2. Execute the `create_roles.sql` script
3. Set secure passwords for all roles:
   ```sql
   ALTER ROLE "app.admin.role" WITH PASSWORD 'your_secure_password';
   ALTER ROLE "app.core.role" WITH PASSWORD 'your_secure_password';
   ALTER ROLE "app.ro.role" WITH PASSWORD 'your_secure_password';
   ```
4. Verify role creation and permissions:
   ```sql
   \du  -- List all roles and their attributes
   ```

## Security Notes

- Change default passwords immediately after creation
- Regularly audit role memberships and permissions
- Review and adjust default privileges as needed
- Monitor role usage and access patterns
- Avoid granting superuser privileges
- Use schema qualification for all objects
