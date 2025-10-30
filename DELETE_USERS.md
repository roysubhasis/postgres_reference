# PostgreSQL User Deletion Guide

This document explains the user deletion process defined in `delete_users.sql`.

## Overview

The script safely removes the following database users:
- `usr.adm.001` (Administrative user)
- `usr.core.001` (Core application user)
- `usr.ro.001` (Read-only user)

## Deletion Process

### 1. Privilege Revocation
First, all privileges are revoked from users to ensure clean removal:
```sql
REVOKE ALL PRIVILEGES FROM "usr.adm.001";
REVOKE ALL PRIVILEGES FROM "usr.core.001";
REVOKE ALL PRIVILEGES FROM "usr.ro.001";
```

### 2. Role Membership Revocation
Remove role assignments:
```sql
REVOKE "app.admin.role" FROM "usr.adm.001";
REVOKE "app.core.role" FROM "usr.core.001";
REVOKE "app.ro.role" FROM "usr.ro.001";
```

### 3. User Deletion
Drop the users with safety checks:
```sql
DROP USER IF EXISTS "usr.adm.001";
DROP USER IF EXISTS "usr.core.001";
DROP USER IF EXISTS "usr.ro.001";
```

## Execution Steps

1. **Pre-deletion Checks**
   - Ensure no active connections from these users
   - Backup any user-specific settings or permissions if needed
   - Document any custom permissions for future reference

2. **Running the Script**
   ```bash
   psql -U postgres -f delete_users.sql
   ```

3. **Verification**
   ```sql
   -- List all users to verify deletion
   \du
   ```

## Safety Measures

1. **IF EXISTS Clause**
   - Prevents errors if users are already deleted
   - Makes the script rerunnable

2. **Privilege Cleanup**
   - Revokes all privileges before deletion
   - Ensures no lingering permissions

3. **Role Membership Cleanup**
   - Removes role assignments explicitly
   - Prevents dependency issues

## Best Practices

1. **Execution Order**
   - Run during maintenance window
   - Ensure no active connections
   - Document the deletion process

2. **Verification**
   - Check for successful deletion
   - Verify no remaining privileges
   - Confirm no dependent objects remain

3. **Documentation**
   - Record when and why users were deleted
   - Keep audit trail of deletion process
   - Update access documentation

## Troubleshooting

If deletion fails:
1. Check for active connections
2. Verify executing user has sufficient privileges
3. Check for dependent objects
4. Review PostgreSQL logs for errors

## Security Considerations

1. **Access Control**
   - Execute as database superuser
   - Verify no active sessions
   - Monitor deletion process

2. **Audit Trail**
   - Log deletion operations
   - Document removal reasons
   - Maintain deletion records

3. **Recovery Planning**
   - Backup user permissions before deletion
   - Document recreation steps if needed
   - Keep configuration history