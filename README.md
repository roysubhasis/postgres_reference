# postgres_reference
Repository for PSQL reference.

## Write a function to create "employee_data" table 

**Schema name:** study  
**Function name:** func_sample_employee_table  
**Table name:** employee_data  

Columns given below,  

    | Column            | Data Type         |
    | ----------------- | ----------------- |
    |   empid           | VARCHAR(10)       |
    |   fname           | VARCHAR(20)       |
    |   lname           | VARCHAR(20)       |
    |   data            | jsonb             |
    |   active          | BOOLEAN(NOT NULL) |
    |   event_timestamp | timestamp         |


You need to perform below 2 Operations.

* Write function which will create the above table by passing the schema and table value as parameter in the function.
* Write SQL to call the function.
