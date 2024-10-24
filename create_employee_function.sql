-- FUNCTION with Parameter to create Table in PSQL.
-- Here we are creating a function "func_sample_employee_table" under "study" schema.

CREATE FUNCTION study.func_sample_employee_table(p_schema_identifier text DEFAULT 'employee_data'::text,
 p_schema_name text DEFAULT 'study'::text, 
 p_table_prefix text DEFAULT ''::text)
 RETURNS INTEGER  
 LANGUAGE 'plpgsql'  
 COST 100  
 VOLATILE PARALLEL UNSAFE  
as $BODY$ 
DECLARE SUCCESS INTEGER; v_create_statement TEXT; v_message TEXT; v_exception_det TEXT; v_exception_hint TEXT; 
v_tbl_name TEXT; v_sql_state TEXT; v_constraint_name TEXT; 
BEGIN
	
	RAISE NOTICE 'args supplied-%, %, %',p_schema_name, p_schema_identifier,p_table_prefix;
	v_tbl_name := lower(trim(p_schema_name)) || '.' || lower(trim(p_table_prefix)) || lower(trim(p_schema_identifier));
	v_constraint_name := 'pk_' || lower(trim(p_table_prefix)) || lower(trim(p_schema_identifier));
	
	
	RAISE NOTICE 'table-%, constraint-%',v_tbl_name,v_constraint_name;
	v_create_statement := 'CREATE TABLE IF NOT EXISTS '
						   || v_tbl_name
						   || '(
								empid VARCHAR(10),
								fname VARCHAR(20),
								lname VARCHAR(20),
								data jsonb,
								active BOOLEAN NOT NULL,								
								event_timestamp timestamp without time zone,
							CONSTRAINT '
							|| v_constraint_name
							|| ' PRIMARY KEY (empid)'
							|| ');';
	SUCCESS = 1;	
		IF EXISTS (SELECT FROM pg_catalog.pg_tables
					WHERE schemaname = p_schema_name 
					AND   tablename  = v_tbl_name) THEN
			RAISE WARNING 'Table % already exists. Exiting....!!! ', v_tbl_name;
			SUCCESS = 0;
		ELSE
			EXECUTE v_create_statement;
			SUCCESS = 0;
		END IF;
	RETURN SUCCESS;
	EXCEPTION WHEN OTHERS then 
		GET STACKED diagnostics 
								v_message = MESSAGE_TEXT, 
								v_sql_state = returned_sqlstate; 
		RAISE NOTICE 'Message : %', v_message;
		RAISE EXCEPTION '%-%-Unable to create the table "%", %', v_sql_state, now(), v_tbl_name, v_message;
	RETURN SUCCESS;
END;
$BODY$;
							
	