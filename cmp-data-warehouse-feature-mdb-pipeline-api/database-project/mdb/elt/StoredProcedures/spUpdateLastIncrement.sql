CREATE PROCEDURE [elt].[spUpdateLastIncrement]
    @source_system_name nvarchar(100),
    @source_entity_name nvarchar(100),
    @source_entity_increment_column nvarchar(100)
AS


BEGIN

    DECLARE @query_statement nvarchar(MAX);

    SELECT @query_statement =
        CASE
            WHEN @source_entity_increment_column IS NOT NULL
                THEN CONCAT('UPDATE elt.MetadataTables SET LastIncrement = ',
                    '(SELECT MAX(',
                    @source_entity_increment_column,
                    ') AS NewLastIncrement FROM ',
                    @source_system_name,
                    '.',
                    @source_entity_name,
                    ') ',
                    'WHERE SystemName = ',
                    '''', @source_system_name, '''',
                    ' AND EntityName = ',
                    '''', @source_entity_name, ''''
                )
            ELSE CONCAT('PRINT(', '''', 'Geen te updaten increment', '''', ')')
        END
        --Maybe add another option that makes the LastIncrement column NULL again if there is no source_entity_increment_column.

END

BEGIN
    EXEC(@query_statement)
END;
