
CREATE PROCEDURE [elt].[spCreateSchema]
        @system_name nvarchar(max)
AS
BEGIN
    DECLARE
        @create_statement nvarchar(max);
    
    BEGIN TRY

 

        BEGIN TRANSACTION
            SELECT DISTINCT @create_statement = CONCAT('CREATE SCHEMA ', '[', @system_name, ']' )
            FROM [elt].[vwMetaDataRaw]
            WHERE [SystemName] = @system_name

 

            --IF NOT EXISTS
            --(
            --    SELECT *
            --    FROM INFORMATION_SCHEMA.SCHEMATA
            --    WHERE [SCHEMA_NAME] = @system_name
            --)
            --BEGIN
            --    Exec (@create_statement)
            --END

        COMMIT TRANSACTION

 

        END TRY

 

        BEGIN CATCH
            ROLLBACK TRANSACTION
        END CATCH

    SELECT Concat('IF NOT EXISTS
            (
                SELECT *
                FROM INFORMATION_SCHEMA.SCHEMATA
                WHERE [SCHEMA_NAME] = '+ '''' + @system_name + '''' + '
            )
			BEGIN'
			,' EXEC('
			,''''
			, @create_statement
			, ''''
			, ')'
			, ' END'
			 )  AS CreateSchemaStatement
    END