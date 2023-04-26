CREATE FUNCTION [elt].[fnCreateQuery](@system_name VARCHAR(64),
                                       @system_type VARCHAR(64),
                                       @schema_name VARCHAR(50),
                                       @entity_name VARCHAR(64),
                                       @process_run_id INT,
                                       @select_query VARCHAR(MAX) = NULL,
                                       @IncrementColumnName VARCHAR(64) = NULL,
                                       @process_run_date DATE = NULL,
                                       @IncrementRange INT = NULL,
                                       @LastIncrementDate DATE = NULL,
                                       @LastIncrementTime TIME(3) = NULL
)
RETURNS VARCHAR(MAX)
AS

-----------------------------------------------------------------------------------------------------------
--Debug:
--DECLARE
--		@system_name NVARCHAR(64) = 'adventureworkslt',
--		@system_type NVARCHAR(64) = 'sqlserver',
--		@schema_name NVARCHAR(50) = 'SalesLT',
--        @entity_name NVARCHAR(64) = 'Customer', 
--		@process_run_id INT = -1,
--		@select_query VARCHAR(MAX) = NULL,
--        @IncrementColumnName NVARCHAR(64) = 'ModifiedDate',
--        @process_run_date  DATE = '2020-08-24',
--        @IncrementRange INT = -1,
--		  @LastIncrementDate DATE = '2009-05-16 16:33:33.123' 
--		  @LastIncrementTime TIME(3) '2009-05-16 16:33:33.123' 
-----------------------------------------------------------------------------------------------------------
BEGIN
    DECLARE @select_clause VARCHAR(MAX);
    SET @select_clause = CASE @system_type
        WHEN 'oracle'
            THEN [elt].[fnCreateOracleQuery](
                @system_name,
                @schema_name,
                @entity_name,
                @process_run_id,
                @select_query,
                @IncrementColumnName,
                @process_run_date,
                @IncrementRange
            )
        WHEN 'sqlserver'
            THEN [elt].[fnCreateSQLServerQuery](
                @system_name,
                @schema_name,
                @entity_name,
                @process_run_id,
                @select_query,
                @IncrementColumnName,
                @process_run_date,
                @IncrementRange,
                @LastIncrementDate,
                @LastIncrementTime
            )
        WHEN 'mysql'
            THEN [elt].[fnCreateMySQLQuery](
                @system_name,
                @entity_name,
                @process_run_id,
                @select_query,
                @IncrementColumnName,
                @process_run_date,
                @IncrementRange
            )
        WHEN 'db2'
            THEN [elt].[fnCreateDB2Query](
                @system_name,
                @schema_name,
                @entity_name,
                @process_run_id,
                @select_query,
                @IncrementColumnName,
                @process_run_date,
                @IncrementRange
            )
        WHEN 'postgres'
            THEN [elt].[fnCreatePostgresQuery](
                @system_name,
                @schema_name,
                @entity_name,
                @process_run_id,
                @select_query,
                @IncrementColumnName,
                @process_run_date,
                @IncrementRange
            )
        END;
    RETURN @select_clause;
END;
