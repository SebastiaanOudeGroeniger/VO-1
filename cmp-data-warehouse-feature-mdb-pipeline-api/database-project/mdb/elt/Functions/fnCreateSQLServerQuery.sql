CREATE
FUNCTION [elt].[fnCreateSQLServerQuery] (
    @system_name NVARCHAR(64),
    @schema_name NVARCHAR(50),
    @entity_name NVARCHAR(64),
    @process_run_id INT,
    @select_query VARCHAR(MAX) = NULL,
    @IncrementColumnName NVARCHAR(64) = NULL,
    @process_run_date DATE = NULL,
    @IncrementRange INT = NULL,
    @LastIncrementDate DATE = NULL,
    @LastIncrementTime TIME(3) = NULL
)

RETURNS VARCHAR(MAX) AS

--Description:		Based on the entity, the associated data is looked up and processed into a SQL Server Query.
--					When data is entered in the Increment parameters, an additional WHERE clause is added to filter by date.
		

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


    DECLARE @select_clause VARCHAR(MAX), @where_clause VARCHAR(MAX)





    IF @select_query IS NOT NULL
        BEGIN
            SET
                @select_clause = REPLACE(
                    @select_query,
                    '<ProcessRunID>',
                    CAST(@process_run_id AS VARCHAR(11)) + ' AS ProcessRunId'
                )
        END
    ELSE
        BEGIN
            SELECT @select_clause = CONCAT('SELECT ', CHAR(32),
                STRING_AGG(CONVERT(VARCHAR(MAX),
                    IIF(
                        DataType = 'geometry',
                        'Cast(' + QUOTENAME(
                            [Name]
                        ) + ' as nvarchar(max)) AS ' + QUOTENAME([Name]),
                        QUOTENAME([Name])), 2),
                    ',')
                WITHIN GROUP (ORDER BY[OrdinalPosition] ASC),
                CHAR(32),
                ',',
                '''',
                @process_run_id,
                '''',
                ' AS ProcessRunId',
                CHAR(32),
                'FROM ',
                '[',
                @schema_name,
                '].[',
                @entity_name,
                ']'
            )
            FROM [elt].[vwMetaDataRaw]
            WHERE [SystemName] = @system_name
                AND [EntityName] = @entity_name
        END


	  --The following options can be used for incremental loading.
	  --You can choose 1 option.
	  --You should uncomment the option you want to use and comment the other one.

	  --Incremental loading option 1
	  --This assumes the last edit date (LastIncrement) of a specified column (IncrementColumnName).
	  --If there is no LastIncrement date yet then no WHERE clause is created. In other words, if after a while you set the increment load by specifying an IncrementColumn the next load is still a full load to after which the last increment is determined.
	  --when these are filled, a WHERE clause containing the name of the column, a 'greater than' sign and a date in DATETIME follows (e.g. WHERE [ModifiedDate] > 'Aug 23 2020 1:00PM')
    
    SELECT @where_clause =
        CASE
            WHEN
                @IncrementColumnName IS NOT NULL
                AND @LastIncrementDate IS NOT NULL
                AND @process_run_date IS NOT NULL
                THEN CONCAT('WHERE', ' ',
                    QUOTENAME(@IncrementColumnName), ' ',
                    '>', ' ',
                    '''',
                    @LastIncrementDate,
                    ' ',
                    @LastIncrementTime,
                    ''''
                --, @LastIncrement
                )
        END;

    RETURN
    CONCAT(@select_clause, CHAR(32), @where_clause);



    --Incremental loading 2
	  --This involves looking at a specific range of data that we want to retrieve from the source.
	  --This is done based on the date the refresh runs and an amount of days back that we want data from.
	  --(e.g. If process_run_date = 24-08-2020 and IncrementRange = -1 then it becomes: WHERE [ModifiedDate] BETWEEN '2020-08-23' AND '2020-08-24')

--	SELECT @where_clause = 
--		CASE
--			WHEN
--			 @IncrementRange IS NOT NULL
--			 AND @IncrementColumnName IS NOT NULL
--            AND @process_run_date IS NOT NULL
--            THEN CONCAT('WHERE', CHAR(32), QUOTENAME(@IncrementColumnName), CHAR(32), '>', CHAR(32), '''', DATEADD(day, @IncrementRange, @process_run_date), '''')
--            ELSE NULL
--        END;
--
--  RETURN
--		CONCAT(@select_clause, CHAR(32), @where_clause);


	  --Incremental loading 3
	  --Here only the data with the date of the process_run_date is retrieved.
	  --e.g., process_run_date = 2020-08-24 then it becomes: WHERE [ModifiedDate] = '2020-08-24'


    --SELECT @where_clause = 
    --	CASE
 --           WHEN @IncrementColumnName IS NOT NULL
 --            AND @process_run_date IS NOT NULL
 --            AND @IncrementRange IS NULL 
 --           THEN CONCAT('WHERE', CHAR(32), QUOTENAME(@IncrementColumnName), CHAR(32), '=', CHAR(32), '''', @process_run_date, '''')
 --           ELSE NULL
 --       END;

    --RETURN
    --	CONCAT(@select_clause, CHAR(32), @where_clause);

END
