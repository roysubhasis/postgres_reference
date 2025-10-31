-- Create sample employees table in schema 'study' and a sequence starting at 1001
-- Run this while connected to 'study_db' as a role that can CREATE objects (ideally "usr.adm.001").

-- 1) Create sequence for user_id starting at 1001
CREATE SEQUENCE IF NOT EXISTS study.user_id_sequence
    START WITH 1001
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- 2) Create employees table (user_id uses the sequence)
CREATE TABLE IF NOT EXISTS study.employees (
    user_id BIGINT PRIMARY KEY DEFAULT nextval('study.user_id_sequence'),
    fname VARCHAR(20),
    lname VARCHAR(20),
    username VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    designation VARCHAR(40),
    created_on TIMESTAMP NOT NULL DEFAULT now()
);

-- 3) Make the sequence owned by the table column so it is dropped/managed with the column
ALTER SEQUENCE study.user_id_sequence OWNED BY study.employees.user_id;

-- 4) Example INSERTs using the sequence implicitly (via DEFAULT) and explicitly
-- Insert using DEFAULT (nextval will be used automatically)
INSERT INTO study.employees (fname, lname, username, email, designation)
VALUES
    ('Alice', 'Anderson', 'alice.a', 'alice@example.com', 'Analyst'),
    ('Bob', 'Brown', 'bob.b', 'bob@example.com', 'Engineer');

-- Insert using explicit nextval() (equivalent)
INSERT INTO study.employees (user_id, fname, lname, username, email, designation, created_on)
VALUES (nextval('study.user_id_sequence'), 'Carol', 'Clark', 'carol.c', 'carol@example.com', 'Manager', now());

-- 5) Verification queries
-- SELECT * FROM study.employees ORDER BY user_id;
-- SELECT last_value, increment_by FROM study.user_id_sequence;

-- End of create_sample_employees.sql
