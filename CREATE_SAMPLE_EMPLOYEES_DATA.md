# Creating and Testing Sample Employee Data

This document outlines the steps to create and test a sample employees table in the `study` schema, demonstrating the role-based access control system.

## Overview

The sample data setup includes:
1. Creating a sequence for employee IDs
2. Creating the employees table
3. Inserting test data
4. Verifying access for different roles

## Prerequisites

- PostgreSQL server is running
- Database `study_db` exists
- Schema `study` is created
- Roles and users are properly set up:
  - `usr.adm.001` (admin user)
  - `usr.core.001` (core user)
  - `usr.ro.001` (read-only user)

## Implementation Steps

### 1. Create and Execute the SQL Script

1. Connect to PostgreSQL as `usr.adm.001`:
```sql
psql -U usr.adm.001 -d study_db
```

2. Execute the `create_sample_employees.sql` script:
```sql
\i create_sample_employees.sql
```

### 2. Verify Access Controls

#### Admin User (`usr.adm.001`)
Should have full access to perform all operations:

```sql
-- Connect as usr.adm.001
psql -U usr.adm.001 -d study_db

-- Test queries
SELECT * FROM study.employees;
INSERT INTO study.employees (first_name, last_name, department) VALUES ('Test', 'Admin', 'IT');
UPDATE study.employees SET department = 'HR' WHERE last_name = 'Admin';
DELETE FROM study.employees WHERE last_name = 'Admin';
```

#### Core User (`usr.core.001`)
Should have CRUD access but cannot modify the sequence or table structure:

```sql
-- Connect as usr.core.001
psql -U usr.core.001 -d study_db

-- Test queries
SELECT * FROM study.employees;
INSERT INTO study.employees (first_name, last_name, department) VALUES ('Test', 'Core', 'Finance');
UPDATE study.employees SET department = 'Sales' WHERE last_name = 'Core';
DELETE FROM study.employees WHERE last_name = 'Core';
```

#### Read-Only User (`usr.ro.001`)
Should only have SELECT access:

```sql
-- Connect as usr.ro.001
psql -U usr.ro.001 -d study_db

-- Test queries (only SELECT should work)
SELECT * FROM study.employees;

-- These should fail
INSERT INTO study.employees (first_name, last_name, department) VALUES ('Test', 'ReadOnly', 'Marketing');
UPDATE study.employees SET department = 'Sales' WHERE employee_id = 1001;
DELETE FROM study.employees WHERE employee_id = 1001;
```

## Expected Results

1. Admin user (`usr.adm.001`):
   - All operations succeed
   - Can modify table structure
   - Can modify sequence

2. Core user (`usr.core.001`):
   - Can SELECT, INSERT, UPDATE, DELETE records
   - Cannot modify table structure
   - Cannot modify sequence

3. Read-only user (`usr.ro.001`):
   - Can only SELECT records
   - All other operations fail with permission errors

## Troubleshooting

If you encounter permission issues:

1. Verify user roles:
```sql
SELECT rolname, rolsuper, rolinherit FROM pg_roles WHERE rolname LIKE 'app%' OR rolname LIKE 'usr%';
```

2. Check schema permissions:
```sql
SELECT * FROM information_schema.role_table_grants WHERE table_schema = 'study' AND table_name = 'employees';
```

3. Verify sequence permissions:
```sql
SELECT * FROM information_schema.role_usage_grants WHERE object_schema = 'study' AND object_name = 'user_id_sequence';
```