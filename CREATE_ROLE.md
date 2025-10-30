# PostgreSQL Role Configuration Guide

This document explains the PostgreSQL roles and permissions defined in `create_roles.sql`.

## Role Overview

The configuration establishes three distinct roles with different privilege levels:

### 1. Administrative Role (`myrole.adm`)

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

### 2. Core Application Role (`myrole.core`)

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

### 3. Read-Only Role (`myrole.ro`)

**Capabilities:**
- Login access
- Does not inherit privileges
- Cannot create databases
- Cannot create roles
- Not a superuser
- No replication capabilities

**Privileges:**
- USAGE on public schema
- SELECT privilege on all tables

## Default Privileges for Future Objects

The configuration automatically sets privileges for newly created objects:

### For `myrole.adm`:
- ALL privileges on new tables
- ALL privileges on new sequences

### For `myrole.core`:
- CRUD operations on new tables
- USAGE and SELECT on new sequences

### For `myrole.ro`:
- SELECT privilege on new tables

## Security Features

1. **Password Protection**
   - All roles are configured with passwords
   - Default passwords should be changed upon first use

2. **Explicit Privilege Grants**
   - All privileges are explicitly defined
   - No implicit permissions

3. **Role Documentation**
   - Each role includes descriptive comments
   - Clear purpose definition for each role

## Best Practices Implemented

1. **Principle of Least Privilege**
   - Each role has only the permissions it needs
   - Hierarchical privilege structure

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

To apply these roles:

1. Connect to your PostgreSQL instance as a superuser
2. Execute the `create_roles.sql` script
3. Change default passwords for all roles
4. Assign users to appropriate roles based on their responsibilities

## Security Notes

- Change default passwords immediately after creation
- Regularly audit role memberships and permissions
- Review and adjust default privileges as needed
- Monitor role usage and access patterns
