
CREATE PROCEDURE [elt].[Load_cmptest]
        @ProcessRunID      INT
,       @PipelineRunID      uniqueidentifier
,       @TaskName           VARCHAR(100)
,	@Schema varchar(max) = 'curated'
,	@EntityName varchar(max) = 'cmptest'
AS
BEGIN
DECLARE @InputInsertedRows       INT = 0
,       @InputUpdatedRows         INT = 0
,       @InputDeletedRows        INT = 0
,       @ErrorCode          INT = 0
,       @ErrorDescription   VARCHAR(MAX)
 

BEGIN TRY  
	BEGIN TRANSACTION

        TRUNCATE TABLE IF EXISTS [curated].[cmptest]

        IF  NOT EXISTS (SELECT * FROM sys.objects
        WHERE object_id = OBJECT_ID(N'[curated].[cmptest]') AND type in (N'U'))

        BEGIN
        CREATE TABLE [curated].[cmptest]
        (
                [Perioden]nvarchar(50) NULL
        ,       [BenzineEuro95_1]float NULL
        ,       [Diesel_2]float NULL
        ,       [Lpg_3]float NULL
        )
        END

        --  insert new records
        INSERT  INTO [curated].[cmptest]
(
            [Perioden]
    ,       [BenzineEuro95_1]
    ,       [Diesel_2]
    ,       [Lpg_3]
)
        SELECT  [V].[Perioden]
        ,       [V].[BenzineEuro95_1]
        ,       [V].[Diesel_2]
        ,       [V].[Lpg_3]
        FROM    [cmp-test].[fuel_prices] V
        
        COMMIT

END TRY
BEGIN CATCH  
        SELECT  @ErrorCode = ERROR_NUMBER()
        ,       @ErrorDescription = ERROR_MESSAGE();  

        IF @@TRANCOUNT > 0  
        BEGIN
                ROLLBACK TRANSACTION; 
        END
END CATCH  

		SELECT
		@ProcessRunID		AS [ProcessRunID]
		,'cmp-test' AS [SourceSchema]
		,'fuel_prices'         AS [SourceTable]
		,'curated'              AS [SinkSchema]
		,'cmptest'      AS [SinkTable]
		,@TaskName		    AS TaskName
		,@InputInsertedRows	AS RowsWritten
		,@InputUpdatedRows 	AS RowsUpdated
		,@InputDeletedRows 	AS RowsDeleted
		,@ErrorDescription	AS ErrorDescription
		,@ErrorCode       	AS ErrorCode
END