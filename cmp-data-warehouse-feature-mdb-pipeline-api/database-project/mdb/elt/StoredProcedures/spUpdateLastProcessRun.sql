CREATE PROCEDURE [elt].[spUpdateLastProcessRun]
    @source_system_name nvarchar(100),
    @source_entity_name nvarchar(100),
    @process_run_date datetime
AS

BEGIN

    DECLARE @query_statement nvarchar(MAX);

    SELECT @query_statement =
        CONCAT('UPDATE elt.MetadataTables SET LastProcessRun = ',
            '''', @process_run_date, '''',
            ' WHERE SystemName = ',
            '''', @source_system_name, '''',
            ' AND EntityName = ',
            '''', @source_entity_name, ''''
        )

END

BEGIN
    EXEC(@query_statement)
END;
