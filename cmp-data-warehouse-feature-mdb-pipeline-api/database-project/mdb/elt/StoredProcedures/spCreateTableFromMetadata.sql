
CREATE PROCEDURE [elt].[spCreateTableFromMetadata]
     @system_name nvarchar(max)
	, @entity_name nvarchar(max)
AS

BEGIN
	DECLARE
		@drop_statement nvarchar(max)
		, @create_statement nvarchar(max)
	
	BEGIN TRY

		BEGIN TRANSACTION

			SELECT @drop_statement = CONCAT('DROP TABLE ', [elt].[fnCreateTableName](@system_name, @entity_name))

			SELECT @create_statement = CONCAT(
										'CREATE TABLE '
										, [elt].[fnCreateTableName](@system_name, @entity_name)
										, '('
										, STRING_AGG(
											CONVERT(varchar(max), CONCAT('['
																		,t.[Name]
																		, '] '
																		, ISNULL(t.[SinkDataType],T.[DataType])
																		, CASE
																			WHEN t.[DataType] = 'XML' THEN ''
																			WHEN t.[DataType] = 'Decimal' THEN Concat('(',NumericPrecision,',',NumericScale,')')
																			WHEN t.[DataType] = 'Numeric' THEN Concat('(',NumericPrecision,',',NumericScale,')') -- Specific exception for XML, the INFORMATION_SCHEMA.COLUMNS gets the value -1 for CharacterMaximumLength but if this is used when creating the table you get an error.
																			WHEN t.[CharacterMaximumLength] = -1 THEN '(MAX)'
																			WHEN t.[CharacterMaximumLength] > 8000 THEN '(MAX)'
																			WHEN t.[DataType] = 'uniqueidentifier' THEN '(36)' -- Uniqueidentifier does not get ingested correctly, so we transform to nvarchar.
																			WHEN t.[CharacterMaximumLength] IS NULL THEN ''
																			ELSE CONCAT('(',  t.[CharacterMaximumLength], ')')
																		END
																		, ' '
																		, IIF(t.[IsNullable] = 'NO', 'NOT NULL', 'NULL')
																  )
											)
										  , ','
										  ) WITHIN GROUP (ORDER BY t.[OrdinalPosition] ASC)
										  , ', [ProcessRunId] INT NOT NULL'
										  , ')'
										  )
			FROM [elt].[vwMetaDataRaw] t
			WHERE 1=1
			AND [elt].[fnCreateTableName](t.SystemName, t.EntityName) = [elt].[fnCreateTableName](@system_name, @entity_name)

--			TJ: The below was working until 22-07-2020, tables with CharacterMaximumLength = -1 failed at this. To test it in the future with an error message from this stored procedure you could use this part again.
--			SELECT @create_statement = CONCAT('CREATE TABLE ', [elt].[fnCreateTableName](@system_name, @entity_name), '(', STRING_AGG(CONVERT(varchar(max), CONCAT('[',t.[Name], '] ', t.[DataType], IIF(t.[CharacterMaximumLength] IS NULL, '', CONCAT('(',  t.[CharacterMaximumLength], ')')), ' ', IIF(t.[IsNullable] = 'NO', 'NOT NULL', 'NULL'))), ',') WITHIN GROUP (ORDER BY t.[OrdinalPosition] ASC), ', [ProcessRunId] INT NOT NULL', ')')
--			FROM [elt].[vwMetaDataRaw] t
--			WHERE 1=1
--			AND [elt].[fnCreateTableName](t.SystemName, t.EntityName) = [elt].[fnCreateTableName](@system_name, @entity_name)

--			DvB: 02-10-2020 Addition when only an active table is rebuilt.

	IF (Select [IsActive] from [elt].[MetadataTables] where @entity_name = EntityName AND SystemName = @system_name) = 1
			BEGIN
			IF NOT EXISTS
			(
				SELECT *
				FROM INFORMATION_SCHEMA.TABLES
				WHERE 1=1
				AND [elt].[fnCreateTableName](TABLE_SCHEMA, TABLE_NAME) = [elt].[fnCreateTableName](@system_name, @entity_name)
			)
			BEGIN
			PRINT 1
				--EXEC(@create_statement)
			END
			ELSE
			BEGIN
			PRINT 2
				--EXEC(@drop_statement)
				--EXEC(@create_statement)
			END
		END
			
		COMMIT TRANSACTION


	END TRY

	BEGIN CATCH
		DECLARE
			@ErrorMessage     NVARCHAR(MAX)
			, @ErrorSeverity  TINYINT
			, @ErrorState     TINYINT
			, @ErrorLine	  TINYINT

		SET @ErrorMessage  = ERROR_MESSAGE()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorState    = ERROR_STATE()
		SET @ErrorLine	   = ERROR_LINE()
		
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorLine)

		ROLLBACK TRANSACTION

	END CATCH

	    Select Concat('IF NOT EXISTS
                (
                    SELECT *
                    FROM INFORMATION_SCHEMA.TABLES
                    WHERE 1=1
                    AND TABLE_SCHEMA = '+ ''''+  @system_name  + ''''+ '
                    AND TABLE_NAME  = '+ ''''+ @entity_name  + '''' + '
                )
                BEGIN
                '
				,' EXEC('
				,''''
				, @create_statement
				, ''''
				, ')'
				, ' END') AS CreateTableStatement

END