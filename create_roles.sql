-- Create administrative role
CREATE ROLE myrole.adm WITH 
    LOGIN
    NOSUPERUSER
    INHERIT
    CREATEDB
    CREATEROLE
    NOREPLICATION
    PASSWORD 'ChangeMe123!';

-- Grant administrative privileges
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO myrole.adm;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO myrole.adm;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO myrole.adm;

-- Create application core role
CREATE ROLE myrole.core WITH 
    LOGIN
    NOSUPERUSER
    INHERIT
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION
    PASSWORD 'ChangeMe123!';

-- Grant core operation privileges
GRANT USAGE ON SCHEMA public TO myrole.core;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO myrole.core;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO myrole.core;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO myrole.core;

-- Create read-only role
CREATE ROLE myrole.ro WITH 
    LOGIN
    NOSUPERUSER
    NOINHERIT
    NOCREATEDB
    NOCREATEROLE
    NOREPLICATION
    PASSWORD 'ChangeMe123!';

-- Grant read-only privileges
GRANT USAGE ON SCHEMA public TO myrole.ro;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO myrole.ro;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT ALL ON TABLES TO myrole.adm;

ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO myrole.core;

ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT SELECT ON TABLES TO myrole.ro;

-- Set default privileges for sequences
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT ALL ON SEQUENCES TO myrole.adm;

ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT USAGE, SELECT ON SEQUENCES TO myrole.core;

COMMENT ON ROLE myrole.adm IS 'Administrative role with database and role creation, manage schema privileges';
COMMENT ON ROLE myrole.core IS 'Application core role with CRUD operation privileges';
COMMENT ON ROLE myrole.ro IS 'Read-only role for querying data only';