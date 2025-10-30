# PostgreSQL Role Deletion Guide

This document explains the role deletion process defined in `delete_roles.sql`.

## Overview

The script safely removes the following database roles:
- `app.admin.role` (Administrative role)
- `app.core.role` (Core application role)
- `app.ro.role` (Read-only role)

## Deletion Process

### 1. Privilege Revocation
Remove all privileges from roles:
```sql
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM "app.admin.role";
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM "app.admin.role";
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM "app.admin.role";
-- (Similar for core and ro roles)
```

### 2. Schema Usage Revocation
Remove schema access:
```sql
REVOKE USAGE ON SCHEMA public FROM "app.admin.role", "app.core.role", "app.ro.role";
```

### 3. Role Hierarchy Cleanup
Remove role inheritance relationships:
```sql
REVOKE "app.core.role" FROM "app.admin.role";
```

### 4. Role Deletion
Drop roles in proper order:
```sql
DROP ROLE IF EXISTS "app.ro.role";
DROP ROLE IF EXISTS "app.core.role";
DROP ROLE IF EXISTS "app.admin.role";
```

## Execution Steps

1. **Pre-deletion Checks**
   - Ensure all users are deleted first
   - Document any custom role permissions
   - Check for role dependencies

2. **Running the Script**
   ```bash
   psql -U postgres -f delete_roles.sql
   ```

3. **Verification**
   ```sql
   -- List all roles to verify deletion
   \du
   ```

## Safety Measures

1. **Deletion Order**
   - Roles deleted in reverse dependency order
   - Prevents cascade deletion issues
   - Maintains database integrity

2. **IF EXISTS Clause**
   - Prevents errors if roles are already deleted
   - Makes the script rerunnable

3. **Privilege Cleanup**
   - Revokes all privileges before deletion
   - Ensures no lingering permissions

## Best Practices

1. **Execution Order**
   - Delete users before roles
   - Run during maintenance window
   - Document the deletion process

2. **Verification**
   - Check for successful deletion
   - Verify no remaining privileges
   - Confirm no dependent objects

3. **Documentation**
   - Record role deletion timing
   - Keep configuration history
   - Update security documentation

## Dependencies

1. **User Deletion**
   - Execute `delete_users.sql` first
   - Verify no user dependencies
   - Check for active sessions

2. **Object Dependencies**
   - Review default privileges
   - Check for custom grants
   - Verify schema permissions

## Troubleshooting

If deletion fails:
1. Check for remaining user assignments
2. Verify all privileges are revoked
3. Check for dependent objects
4. Review PostgreSQL logs

## Security Considerations

1. **Access Control**
   - Execute as superuser only
   - Verify no active role usage
   - Monitor deletion process

2. **Audit Trail**
   - Log deletion operations
   - Document removal reasons
   - Maintain security records

3. **Recovery Planning**
   - Backup role configurations
   - Document recreation steps
   - Keep permission templates

## Restoration Process

If roles need to be recreated:
1. Use original `create_roles.sql`
2. Restore from documented configuration
3. Verify role hierarchy
4. Test permissions