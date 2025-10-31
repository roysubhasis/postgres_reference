-- Create sequence for user IDs
CREATE SEQUENCE study.user_id_sequence
    START WITH 1001
    INCREMENT BY 1
    NO MAXVALUE
    NO CYCLE;

-- Create users table
CREATE TABLE study.users (
    user_id INTEGER PRIMARY KEY DEFAULT nextval('study.user_id_sequence'),
    fname VARCHAR(20),
    lname VARCHAR(20),
    username VARCHAR(20) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,  -- Length suitable for hashed passwords
    email VARCHAR(75) UNIQUE NOT NULL,
    salary INTEGER CHECK (salary >= 0),
    designation VARCHAR(45),
    created_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Grant permissions to roles
GRANT SELECT, INSERT, UPDATE, DELETE ON study.users TO app.core.role;
GRANT SELECT ON study.users TO app.ro.role;
GRANT USAGE ON SEQUENCE study.user_id_sequence TO app.core.role;

-- Insert sample data
INSERT INTO study.users (
    fname, lname, username, password, email, salary, designation
) VALUES 
    ('John', 'Doe', 'jdoe', 'pass1005', 'jdoe@email.com', 18000, 'Senior Developer'),
    ('Jane', 'Smith', 'jsmith', 'pass1006', 'jsmith@email.com', 16000, 'Data Analyst');

-- Verification queries
SELECT * FROM study.users ORDER BY user_id;