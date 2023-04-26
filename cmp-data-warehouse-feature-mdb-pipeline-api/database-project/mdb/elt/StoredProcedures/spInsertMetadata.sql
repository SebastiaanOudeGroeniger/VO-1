CREATE PROCEDURE [elt].[spInsertMetadata]
(       @SystemCode	varchar(100) -- = 'adventureworks'
,		@SystemType	varchar(100) -- = (SqlServer, MySQLServer, Json, SalesForce)
,		@SystemName sysname -- 'adventureworkslt' (Table_catalog for filling)
,		@lSchema sysname    --= 'TOB'
,       @lTable sysname     --= 'PMEOBJECT'
--,		@lIncrementField varchar(255) --='ModifiedDate'
,		@Json varchar(max) --=  $(LookupName).output.value
)
AS

SET NOCOUNT ON; 

DECLARE   @lID int 
		, @lSQL varchar(max) = ''
		, @DSQL varchar(MAX)
		, @CSQL varchar(MAX)
		, @Message varchar(max)
		, @SystemActive bit
		, @TableActive bit
		, @FirstTime bit

PRINT CHAR(13) + '*** Checking System Type ***' 

IF @SystemType NOT IN 
			( 'SqlServer'
			, 'MySQLServer'
			, 'Json'
			, 'SalesForce'
			, 'Oracle')
BEGIN
	RAISERROR('Correct System type is required, accepted values: (SqlServer, MySQLServer, Json, SalesForce, Oracle)', 16,16)
END	
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
Set All Variables
- SystemActive to determine actions
- TableActive to determine actions
- FirstTime to check if this is a new table
*/
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SET @SystemActive = (SELECT TOP 1 [Active] FROM [elt].[MetadataSystem] 
						WHERE 1=1 
						AND [SystemCode] = @SystemCode
						AND [SystemName] = @SystemName
						AND [SystemType] = @SystemType);

PRINT CHAR(13) + '*** Set SystemActive = ' + trim(str(@SystemActive)) + ' ***' 

IF EXISTS (SELECT TOP 1 [IsActive] FROM [elt].[MetadataTables]
					WHERE 1=1 
					AND [SystemCode] = @SystemCode
					AND [SystemName] = @SystemName
					AND [SchemaName] = @lSchema	
					AND [EntityName] = @lTable
					AND [IsActive] = 1
					)		
	BEGIN 
	SET @TableActive = 1
	END
	ELSE 
	SET @TableActive = 0;
	
PRINT '*** Set @TableActive = ' + trim(str(@TableActive)) + ' ***'

/*Inserts required metadata tables records into UseCaseEntity table */
MERGE INTO [elt].[UseCaseEntity] AS Target
USING (
    SELECT
        [MetadataTables].[SystemCode],
        [MetadataTables].[EntityName],
        [MetadataTables].[SchemaName],
        [MetadataTables].[IsActive]
    FROM [elt].[MetadataTables]
) AS Source ([SystemCode], [EntityName], [SchemaName], [IsActive])
ON
    Target.[EntityName] = Source.[EntityName] AND Target.[UseCaseCode] = Source.[SystemCode]
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([UseCaseCode], [SystemCode], [EntityName], [SchemaName], [Active])
    VALUES (Source.[SystemCode], Source.[SystemCode], Source.[EntityName], Source.[SchemaName], Source.[IsActive]);


/*Inserts distinct metadata tables records into UseCase table */
MERGE INTO [elt].[UseCase] AS Target
USING (
    SELECT DISTINCT
        [SystemName],
        [SystemCode],
        [IsActive]
    FROM [elt].[MetadataTables]
) AS Source ([UseCaseName], [UseCaseCode], [Active])
ON Target.[UseCaseCode] = Source.[UseCaseCode]
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([UseCaseName], [UseCaseCode], [Active])
    VALUES (Source.[UseCaseName], Source.[UseCaseCode], Source.[Active]);

	
IF NOT EXISTS ( SELECT top 1 * from [elt].[MetadataStructure]
								WHERE [SystemCode] = @SystemCode
								AND [SystemName] = @SystemName
								AND [SchemaName] = @lSchema
								AND [EntityName] = @lTable
				)
		BEGIN 
			SET @FirstTime = 1
		END
		ELSE 
			SET @FirstTime = 0
PRINT '*** Set @FirstTime = ' + trim(str(@FirstTime)) + ' ***'	

  DECLARE @RetryCounter INT
  SET @RetryCounter = 0
  RETRY:
  BEGIN TRY

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
Adding the records of the source system to the [elt].[MetadataTables] table. 
	Active records are deleted and inserted with the last know values. 
	Inactive records are skipped
	New records are instered with [IsActive] = 0 
*/
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	PRINT CHAR(13) + '*** Execute spInsertTable if SystemActive = 1 ***'

	IF @SystemActive = 1
	BEGIN
	EXECUTE [elt].[spInsertTable] @systemcode,@systemname,@lschema,@lTable;
	
	PRINT '*** Executed spInsertTable if SystemActive = 1 ***'

	END
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
Adding the records of the source system to the [elt].[MetadataStructure] table
	Update of deleted source system Columns to [Inactive] = 0  and [IsDeleted] = 1
	Inserting values into temp table to later compare to see if new columns have been added
	Deletion of all acitve Columns to insert new values without duplicates
	Inserting all values from input JSON
	Compare with temp table and update records that where modified in MDDB db	
*/
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  BEGIN TRANSACTION 
  BEGIN
  PRINT CHAR(13) + '*** Begin Transaction ***'

	IF @TableActive = 1
			
			BEGIN
			/* Update Removed Columns in source to IsActive = 0 and Is Deleted = 1 if Column not in Json*/ 
				PRINT CHAR(13) + '*** Update Columns in elt.MetadataStructure that are not in the source ***'				
								
						UPDATE [elt].[MetadataStructure] WITH (ROWLOCK)  -- Trying via merge with an other update!
						SET   IsActive  = 0
							, IsDeleted = 1
							, LastModifiedDate = GETDATE()
						WHERE [SystemCode] = @SystemCode
						AND [SystemName] = @SystemName
						AND [SchemaName] = @lSchema
						AND [EntityName] = @lTable
						AND [Name] NOT IN (SELECT JS.COLUMN_NAME 
											FROM OPENJSON(@Json)
														WITH (									
															[COLUMN_NAME] nvarchar(500) '$.COLUMN_NAME'
															) AS JS
											)
			END
			PRINT CHAR(13) + '*** Succesfully Update Columns in elt.MetadataStructure that are not in the source ***';


	IF @TableActive = 1
			BEGIN
			/*TEMP table for later comparison between new and old values*/
				PRINT CHAR(13) + '*** Insert into Temp Table ***'
					
					--CREATE TABLE #TempColumns
					--(
					--	[SystemCode] [nvarchar](30) NOT NULL,
					--	[SystemName] [nvarchar](64) NOT NULL,
					--	[SchemaName] [nvarchar](50) NOT NULL,
					--	[EntityName] [nvarchar](64) NOT NULL,
					--	[Name] [nvarchar](128) NOT NULL,
					--	[SemanticName]  [nvarchar](128) NULL,
					--	[DataType] [nvarchar](16) NOT NULL,
					--	[CharacterMaximumLength] [bigint] NULL,
					--	[IsNullable] [nvarchar](4) NOT NULL,
					--	[OrdinalPosition] [int] NOT NULL,
					--	[NumericPrecision] [int] NULL,
					--	[NumericScale] [int] NULL,
					--	[DatetimeCulture] [nvarchar](64) NULL,
					--	[DatetimeFormat] [nvarchar](64) NULL,
					--	[IsActive] [bit] NULL,
					--	[IsPrimaryKey] [int] NULL,
					--	[PrimaryKeyOrdinal] [int] NULL,
					--	[IsHistory] [bit] NOT NULL,
					--	[LastModifiedDate] [datetime] NULL,
					--	[isDeleted] [bit] NULL
					--)
					--INSERT INTO #TempColumns
					SELECT [SystemCode]
						   ,[SystemName]
						   ,[SchemaName]
						   ,[EntityName]
						   ,[Name]
						   ,[SemanticName]
						   ,[DataType]
						   ,[CharacterMaximumLength]
						   ,[IsNullable]
						   ,[OrdinalPosition]
						   ,[NumericPrecision]
						   ,[NumericScale]
						   ,[DatetimeCulture]
						   ,[DatetimeFormat]
						   ,[IsActive]
						   ,[IsPrimaryKey]
						   ,[PrimaryKeyOrdinal]
						   ,[IsHistory]
						   ,[LastModifiedDate]
						   ,[IsDeleted]
					INTO #TempColumns
					FROM [elt].[MetadataStructure]
					WHERE [SystemCode]   = @SystemCode
						AND [SystemName] = @SystemName
						AND [SchemaName] = @lSchema
						AND [EntityName] = @lTable;
		
				
			/*Delete All Active rows that will Be updated from the Metadata Table */
				PRINT CHAR(13) + '*** Delete IsActive recods from elt.MetadataStructure  ***'
		
					DELETE FROM [elt].[MetadataStructure] With (ROWLOCK)
					WHERE   [SystemCode] = @SystemCode
						AND [SystemName] = @SystemName
						AND [SchemaName] = @lSchema
						AND [EntityName] = @lTable
						AND [Name] IN (SELECT  [Name] 
									   FROM    [elt].[MetadataStructure] 
									   WHERE   [SystemCode]			= @SystemCode
												AND [SystemName]	= @SystemName
												AND [SchemaName]	= @lSchema
												AND [EntityName]	= @lTable
												AND [IsActive]		= 1
										)
					END
			ELSE
				BEGIN
					 Set @Message = 'This Table is Inactive'
				END

	PRINT CHAR(13) + '*** Execute spInsertStructure' + @SystemType + ' ***'
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
						
				/* For a MySQL SourceSystem use this query in the ADF LookUp:
				
				@concat('Select '
				, 'TABLE_CATALOG, ' 
				, 'COLUMN_NAME, ' 
				, 'DATA_TYPE, ' 
				, 'CHARACTER_MAXIMUM_LENGTH, '
				, 'numeric_precision, '
				, 'numeric_scale, ' 
				, 'IS_NULLABLE, '
				, 'ORDINAL_POSITION'
				, ' From Information_schema.columns 
				WHERE TABLE_NAME = ', '''', item().TABLE_NAME , '''' 
				, ' AND TABLE_SCHEMA = ', '''' , item().TABLE_SCHEMA, '''')
				
				*/
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
				IF @SystemType = 'MySqlServer'
				AND @TableActive = 1

				OR @SystemType = 'MySqlServer'
				AND @TableActive = 0 AND @FirstTime = 1
				
							BEGIN

				EXECUTE  [elt].[spInsertStructureMySQL] @systemcode,@SystemName, @lSchema, @lTable, @Json
							
							 END 																		 	
							 ELSE 
							 SET @Message = 'This Table is Inactive'								 																					 	
		
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
				/* For a MSSql SourceSystem use this query in the ADF LookUp:
				
				@concat('SELECT 
						*
						FROM INFORMATION_SCHEMA.COLUMNS 
						WHERE TABLE_NAME = ',  '''' , string(item().Table_name) , '''' 
						, 'AND TABLE_SCHEMA = ', '''' , string(item().Schema_name) , '''' 
						)
				
				*/
				
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
				IF @SystemType = 'SqlServer'
				AND @TableActive = 1

				OR @SystemType = 'SqlServer'
				AND @TableActive = 0 AND @FirstTime = 1
				
							BEGIN

				EXECUTE  [elt].[spInsertStructureSQL] @systemcode,@SystemName, @lSchema, @lTable, @Json
							
							END 																		 	
							ELSE
							SET @Message = 'This Table is Inactive'								 	
																									 
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
				
				/* For a SalesForce SourceSystem use this query in the ADF LookUp
				@concat('SELECT Length
				,QualifiedApiName
				,ServiceDataTypeId
				,IsNillable
				,Precision
				,Scale FROM FieldDefinition
				WHERE EntityDefinitionId= ', '''' , item().QualifiedApiName,  '''')
				*/
		
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
				IF @SystemType = 'SalesForce'
				AND @TableActive = 1

				OR @SystemType = 'SalesForce'
				AND @TableActive = 0 AND @FirstTime = 1
				
							BEGIN
							 
				EXECUTE [elt].[spInsertStructureSalesForce] @systemcode, @SystemName ,@lSchema, @lTable, @Json
							
							END 																		 	
							ELSE
							SET @Message = 'This Table is Inactive'				

		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
				
				/* For a Json format use a GetMetadata Acitivity in ADF that looks at the Storage Container Blob with the data. 
				   Be sure to use the setting 'Fields' : 'Structure'
				*/
		
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
				IF @SystemType = 'Json'
				AND @TableActive = 1

				OR @SystemType = 'Json'
				AND @TableActive = 0 AND @FirstTime = 1

				
							BEGIN
							 
				EXECUTE [elt].[spInsertStructureJson] @systemcode, @SystemName ,@lSchema, @lTable, @Json
							
							END 																		 	
							ELSE
							SET @Message = 'This Table is Inactive'		

		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
				
				/* For a Oracle SourceSystem use this query in the ADF LookUp for Tables:
																			 SELECT at.OWNER AS SCHEMA_NAME,
																			 at.TABLE_NAME AS TABLE_NAME,
																			 at.NUM_ROWS AS ROWCOUNT
																			FROM all_tables at
																			WHERE at.NUM_ROWS > 0
																			--AND at.OWNER = 'SCHEMA_NAME'
				   For a Oracle SourceSystem use this query in the ADF LookUp for Columns: 
				   @concat('(select GLOBAL_NAME from global_name) TABLE_CATALOG
								,COLUMN_NAME
								,DATA_TYPE
								,CHAR_LENGTH AS CHARACTER_MAXIMUM_LENGTH
								,DATA_PRECISION AS numeric_precision
								,DATA_SCALE AS numeric_scale
								,NULLABLE AS IS_NULLABLE
								,COLUMN_ID AS ORDINAL_POSITION
								FROM all_tab_columns
								WHERE TABLE_NAME = ','''' , string(item().Table_name) , '''' ,
								'AND OWNER = ', '''' , string(item().Schema_name) , '''' )
				*/
		
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
				IF @SystemType = 'Oracle'
				AND @TableActive = 1

				OR @SystemType = 'Oracle'
				AND @TableActive = 0 AND @FirstTime = 1

		
				    		BEGIN

				EXECUTE  [elt].[spInsertStructureOracle] @systemcode,@lSchema, @lTable, @Json
							
							END 																		 	
							ELSE
							SET @Message = 'This Table is Inactive'											 	
		
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		/*
		Update new columns from source where not is source before this run to isActive = 0 
		*/
		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	IF @TableActive = 1
	--AND EXISTS (select top 1 * from #TempColumns) 	
			BEGIN

		-- Set PK, Semanctic and metadata Values to values from before run
					UPDATE [elt].[MetadataStructure] WITH (ROWLOCK)
					SET  IsPrimaryKey = T.IsPrimaryKey
						,SemanticName = T.SemanticName
						,IsHistory    = T.IsHistory
						,IsDeleted    = T.IsDeleted
						,IsActive     = CASE WHEN NOT EXISTS (Select [Name] FROM [elt].[MetadataStructure]
																		WHERE SystemCode = T.SystemCode
																		AND  SystemName	 = T.SystemName
																		AND  SchemaName	 = T.SchemaName
																		AND  EntityName	 = T.EntityName
																		AND [Name] = T.[Name]) then 0 else T.IsActive END --Determine if the column is newly added
					FROM #TempColumns T
					LEFT JOIN [elt].[MetadataStructure] M
							ON T.SystemCode =  M.SystemCode
							AND T.SystemName = M.SystemName
							AND t.SchemaName = M.SchemaName
							AND T.EntityName = M.EntityName
							AND t.Name = M.Name

			SET @Message = 'Insertion of Metadata Succesfull'
			END
	END

  COMMIT TRANSACTION 

  PRINT CHAR(13) + '*** Transaction Committed ***'

END TRY

BEGIN CATCH
	DECLARE
		  @ErrorMessage     NVARCHAR(MAX)
		, @ErrorSeverity    TINYINT
		, @ErrorState       TINYINT
		, @ErrorLine	    TINYINT

	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine	   = ERROR_LINE()
	
	ROLLBACK TRANSACTION
	
	PRINT CHAR(13) + '*** Transaction Rollback ***'
	PRINT ERROR_NUMBER() 
	
	IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
	BEGIN 
		IF (@RetryCounter > 3)
		BEGIN
			RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorLine, @message)
		END
		ELSE
		BEGIN
			SET @RetryCounter = @RetryCounter + 1
			WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
			GOTO RETRY -- Go to Label RETRY
			PRINT CHAR(13) + '*** Go to Retry ***'
		END
	END
	ELSE
	BEGIN
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorLine, @message)
	END

END CATCH