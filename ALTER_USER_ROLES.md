# PostgreSQL User Role Modification Guide

This document explains how to modify user roles and permissions as defined in `alter_user_roles.sql`.

## Common Role Operations

### 1. Revoking Roles
```sql
REVOKE "app.admin.role" FROM "usr.adm.001";
REVOKE "app.core.role" FROM "usr.core.001";
REVOKE "app.ro.role" FROM "usr.ro.001";
```

### 2. Role Reassignment Examples

#### Demote Admin to Core User
```sql
REVOKE "app.admin.role" FROM "usr.adm.001";
GRANT "app.core.role" TO "usr.adm.001";
```

#### Promote Core User to Admin
```sql
REVOKE "app.core.role" FROM "usr.core.001";
GRANT "app.admin.role" TO "usr.core.001";
```

#### Restrict to Read-Only
```sql
REVOKE "app.core.role" FROM "usr.core.001";
GRANT "app.ro.role" TO "usr.core.001";
```

## User Attribute Modifications

### Login Control
```sql
-- Disable login
ALTER USER "usr.adm.001" WITH NOLOGIN;

-- Enable login
ALTER USER "usr.adm.001" WITH LOGIN;
```

### Privilege Modifications
```sql
ALTER USER "usr.adm.001" WITH 
    NOINHERIT
    NOCREATEDB
    NOCREATEROLE;
```

### Password Management
```sql
ALTER USER "usr.adm.001" WITH PASSWORD 'new_secure_password';
```

## Best Practices

### 1. Pre-modification Steps
- Backup current permissions
- Document intended changes
- Plan for service interruptions
- Notify affected users

### 2. During Modification
- Make changes during low-traffic periods
- Test changes immediately
- Keep track of all modifications
- Follow least-privilege principle

### 3. Post-modification Steps
- Verify new permissions
- Test user access
- Update documentation
- Monitor for issues

## Security Considerations

### 1. Access Control
- Review all permission changes
- Validate role assignments
- Check inheritance chains
- Monitor privilege escalation

### 2. Audit Trail
- Log all role changes
- Document reasons for changes
- Track permission modifications
- Maintain change history

### 3. Monitoring
- Check for unauthorized access
- Monitor failed login attempts
- Review access patterns
- Verify permission boundaries

## Verification Steps

### 1. Check User Roles
```sql
\du "usr.adm.001"
```

### 2. Test Access
```sql
-- Test new permissions
SELECT has_table_privilege('usr.adm.001', 'table_name', 'SELECT');
```

### 3. Review Memberships
```sql
SELECT rolname FROM pg_roles WHERE pg_has_role('usr.adm.001', oid, 'member');
```

## Troubleshooting

### Common Issues
1. **Permission Denied**
   - Verify role assignments
   - Check inheritance settings
   - Review schema permissions

2. **Login Failures**
   - Check LOGIN/NOLOGIN status
   - Verify password changes
   - Review connection limits

3. **Privilege Escalation**
   - Audit role memberships
   - Check inheritance chains
   - Review default privileges

## Recovery Procedures

### 1. Immediate Recovery
```sql
-- Restore original role
GRANT "original_role" TO "username";
```

### 2. Full Reset
```sql
-- Reset to default state
REVOKE ALL PRIVILEGES FROM "username";
GRANT "intended_role" TO "username";
```

## Maintenance

### Regular Tasks
1. Review role assignments
2. Audit permission changes
3. Update documentation
4. Test access controls

### Documentation Updates
1. Keep role modification history
2. Update user-role mappings
3. Maintain permission matrices
4. Document emergency procedures