# Users Table Creation and Management

This document describes the creation and management of the `users` table in the `study` schema, including its structure, permissions, and usage examples.

## Table Structure

The `users` table contains the following columns:

| Column      | Type         | Constraints                 | Description                    |
|-------------|--------------|----------------------------|--------------------------------|
| user_id     | INTEGER      | PRIMARY KEY                | Auto-generated using sequence  |
| fname       | VARCHAR(20)  |                            | First name                     |
| lname       | VARCHAR(20)  |                            | Last name                      |
| username    | VARCHAR(20)  | UNIQUE, NOT NULL           | Unique username               |
| password    | VARCHAR(255) | NOT NULL                   | Hashed password storage        |
| email       | VARCHAR(75)  | UNIQUE, NOT NULL           | User's email address          |
| salary      | INTEGER      | CHECK (salary >= 0)        | Employee salary               |
| designation | VARCHAR(45)  |                            | Job designation               |
| created_on  | TIMESTAMP    | NOT NULL, DEFAULT now()    | Record creation timestamp     |

## Prerequisites

- PostgreSQL server is running
- Database `study_db` exists
- Schema `study` is created
- Roles and users are properly set up:
  - `usr.adm.001` (admin user)
  - `usr.core.001` (core user with CREATE permission on schema)
  - `usr.ro.001` (read-only user)
- Additional permissions required:
  - `GRANT CREATE ON SCHEMA study TO app.core.role;` (must be run by admin)

## Implementation Steps

### 1. Grant Required Permissions

First, connect as admin to grant necessary permissions:
```sql
psql -U usr.adm.001 -d study_db

-- Grant CREATE permission to core role
GRANT CREATE ON SCHEMA study TO app.core.role;
```

### 2. Create and Execute the SQL Script

Connect to PostgreSQL as `usr.core.001`:
```sql
psql -U usr.core.001 -d study_db
```

Execute the script:
```sql
\i create_users_table.sql
```

### 3. Verify Access Controls

#### Table Owner (`usr.core.001`)
```sql
-- Already connected as usr.core.001
-- Full access tests as table owner
SELECT * FROM study.users;
INSERT INTO study.users (fname, lname, username, password, email, salary, designation)
VALUES ('Test', 'Admin', 'tadmin', 'pass1007', 'tadmin@email.com', 20000, 'Manager');
UPDATE study.users SET salary = 21000 WHERE username = 'tadmin';
DELETE FROM study.users WHERE username = 'tadmin';
```

#### Core User (`usr.core.001`)
```sql
-- Connect as usr.core.001
psql -U usr.core.001 -d study_db

-- CRUD operation tests
SELECT * FROM study.users;
INSERT INTO study.users (fname, lname, username, password, email, salary, designation)
VALUES ('Test', 'Core', 'tcore', 'pass1008', 'tcore@email.com', 17000, 'Developer');
UPDATE study.users SET salary = 18000 WHERE username = 'tcore';
DELETE FROM study.users WHERE username = 'tcore';
```

#### Read-Only User (`usr.ro.001`)
```sql
-- Connect as usr.ro.001
psql -U usr.ro.001 -d study_db

-- Only SELECT should work
SELECT * FROM study.users;

-- These should fail with permission errors
INSERT INTO study.users (fname, lname, username, password, email, salary, designation)
VALUES ('Test', 'ReadOnly', 'tro', 'pass1009', 'tro@email.com', 16000, 'Analyst');
UPDATE study.users SET salary = 17000 WHERE username = 'ssahoo';
DELETE FROM study.users WHERE username = 'ssahoo';
```

### 4. Additional Admin Steps

After table creation, the admin user should review and adjust permissions if needed:
```sql
-- Connect as admin to review/adjust permissions
psql -U usr.adm.001 -d study_db

-- Verify table ownership and permissions
SELECT schemaname, tablename, tableowner 
FROM pg_tables 
WHERE schemaname = 'study' AND tablename = 'users';

-- Optionally adjust permissions if needed
GRANT SELECT ON study.users TO app.ro.role;
```

## Security Considerations

1. Password Storage:
   - Never store plain-text passwords in production
   - Use proper password hashing algorithms (e.g., bcrypt, Argon2)
   - The password field is sized for hashed values (255 characters)

2. Access Control:
   - Core users have full CRUD access but cannot modify table structure
   - Read-only users can only SELECT
   - Only admin users can modify table structure or grants

3. Data Validation:
   - Username and email must be unique
   - Salary cannot be negative
   - All critical fields are NOT NULL

## Troubleshooting

### Check Table Permissions
```sql
SELECT grantee, privilege_type 
FROM information_schema.role_table_grants 
WHERE table_schema = 'study' 
AND table_name = 'users';
```

### Verify Sequence Permissions
```sql
SELECT grantee, privilege_type 
FROM information_schema.role_usage_grants 
WHERE object_schema = 'study' 
AND object_name = 'user_id_sequence';
```

### Check Constraint Violations
```sql
-- For duplicate usernames/emails
SELECT username, COUNT(*) 
FROM study.users 
GROUP BY username 
HAVING COUNT(*) > 1;

SELECT email, COUNT(*) 
FROM study.users 
GROUP BY email 
HAVING COUNT(*) > 1;

-- For negative salaries
SELECT * FROM study.users WHERE salary < 0;
```