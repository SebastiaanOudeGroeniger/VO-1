CREATE PROCEDURE [audit].[spInsertDataLogStaging]
    @pipeline_run_id uniqueidentifier,
    @process_run_id [int],
    @system_name [nvarchar](100),
    @entity_name [nvarchar](100)


AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        INSERT INTO [audit].[DataLog]
        SELECT
            @process_run_id,
            @pipeline_run_id,
            'Staging',
            @system_name,
            @entity_name,
            sys.dm_db_partition_stats.row_count,
            NULL,
            NULL,
            sys.dm_db_partition_stats.row_count,
            GETDATE() AS logdate
        FROM sys.tables
        INNER JOIN sys.dm_db_partition_stats
            ON sys.tables.object_id = sys.dm_db_partition_stats.object_id
                -- 0 = Heap, 1 = Clustered index, >= 2 = nonclustered index
                AND sys.dm_db_partition_stats.index_id IN (0, 1)
        INNER JOIN sys.schemas
            ON sys.schemas.schema_id = sys.tables.schema_id
                AND sys.schemas.name = @system_name
        WHERE 1 = 1
            --see fnCreateTableName
            AND sys.tables.name = @entity_name
    /*LOWER(REPLACE(@entity_name, ' ', '_'))*/


        COMMIT TRANSACTION

    END TRY

    BEGIN CATCH
        DECLARE
            @ErrorMessage nvarchar(MAX),
            @ErrorSeverity tinyint,
            @ErrorState tinyint,
            @ErrorLine tinyint

        SET @ErrorMessage = ERROR_MESSAGE()
        SET @ErrorSeverity = ERROR_SEVERITY()
        SET @ErrorState = ERROR_STATE()
        SET @ErrorLine = ERROR_LINE()

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorLine)

        ROLLBACK TRANSACTION

    END CATCH


END
