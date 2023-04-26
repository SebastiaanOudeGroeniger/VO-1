CREATE PROCEDURE [elt].[spCreateSchema]
    @create_schema_script nvarchar(MAX)
AS

--Note: this parameter is fed from Synapse
BEGIN TRY
    BEGIN TRANSACTION
    EXEC(@create_schema_script)
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
