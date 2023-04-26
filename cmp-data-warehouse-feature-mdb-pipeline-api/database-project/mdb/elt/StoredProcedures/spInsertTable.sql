CREATE PROCEDURE [elt].[spInsertTable]
    (
        @SystemCode nvarchar(128),
        @SystemName nvarchar(128),
        @lSchema nvarchar(128),
        @lTable nvarchar(128)
    )
AS

DECLARE @TableActive bit = 1
DECLARE @FirstTime bit
DECLARE @DeleteTable varchar(MAX)
DECLARE @ErrorMessage nvarchar(MAX)
DECLARE @ErrorSeverity tinyint
DECLARE @ErrorState tinyint
DECLARE @ErrorLine tinyint


CREATE TABLE #TempMetadataTables(
    [SystemCode] [nvarchar](30) NOT NULL,
    [SystemName] [nvarchar](64) NOT NULL,
    [SchemaName] [nvarchar](50) NOT NULL,
    [EntityName] [nvarchar](64) NOT NULL,
    [CopyToRaw] [bit] NOT NULL,
    [CopyToStg] [bit] NOT NULL,
    [SourceQuery] [nvarchar](MAX) NULL,
    [IsActive] [bit] NULL,
    [LastProcessRun] [datetime] NULL,
    [IncrementColumnName] [nvarchar](64) NULL,
    [IncrementRange] [int] NULL,
    [LastIncrement] [datetime] NULL
)
INSERT INTO #TempMetadataTables
SELECT
    [SystemCode],
    [SystemName],
    [SchemaName],
    [EntityName],
    [CopyToRaw],
    [CopyToStg],
    [SourceQuery],
    [IsActive],
    [LastProcessRun],
    [IncrementColumnName],
    [IncrementRange],
    [LastIncrement]
FROM [elt].[MetadataTables]
WHERE [SystemCode] = @SystemCode
    AND [SystemName] = @SystemName
    AND [SchemaName] = @lSchema
    AND [EntityName] = @lTable


IF EXISTS (SELECT TOP 1 * FROM elt.metadatatables
    WHERE [SystemCode] = @SystemCode
        AND [SystemName] = @SystemName
        AND [SchemaName] = @lSchema
        AND [EntityName] = @lTable
        AND isactive = 1
)

BEGIN
    SET @TableActive = 1
END
ELSE
    BEGIN
        SET @TableActive = 0
    END

IF NOT EXISTS (SELECT TOP 1 * FROM elt.metadatastructure
    WHERE [SystemCode] = @SystemCode
        AND [SystemName] = @SystemName
        AND [SchemaName] = @lSchema
        AND [EntityName] = @lTable
)
BEGIN
    SET @FirstTime = 1
END
ELSE
    BEGIN
        SET @Firsttime = 0
    END


SET @DeleteTable = ('DELETE from [elt].[MetadataTables]
							WHERE [SchemaName] = ' + '''' + @lSchema + '''' + '
							AND [EntityName] = ' + '''' + @lTable + '''')
IF @TableActive = 1 AND @FirstTime = 0
    BEGIN TRY
        BEGIN TRANSACTION
        EXEC(@DeleteTable)

        INSERT INTO [elt].[MetadataTables]
        ([SystemCode],
            [SystemName],
            [SchemaName],
            [EntityName],
            [CopyToRaw],
            [CopyToStg],
            [SourceQuery],
            [IsActive],
            [LastProcessRun],
            [IncrementColumnName],
            [IncrementRange],
            [LastIncrement],
            [LastModified])

        SELECT
            @SystemCode,
            @SystemName,
            @lSchema,
            @lTable,
            [CopyToRaw],
            [CopyToStg],
            [SourceQuery],
            1,
            [LastProcessRun],
            [IncrementColumnName],
            [IncrementRange],
            [LastIncrement],
            getdate()
        FROM #TempMetadataTables
        COMMIT
    END TRY

    BEGIN CATCH

        SET @ErrorMessage = error_message()
        SET @ErrorSeverity = error_severity()
        SET @ErrorState = error_state()
        SET @ErrorLine = error_line()

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorLine)

        ROLLBACK TRANSACTION

    END CATCH
ELSE
    BEGIN

        IF @TableActive = 0 AND @FirstTime = 1
            BEGIN TRY
                BEGIN TRANSACTION
                EXEC(@DeleteTable)
                INSERT INTO [elt].[MetadataTables]
                ([SystemCode],
                    [SystemName],
                    [SchemaName],
                    [EntityName],
                    [CopyToRaw],
                    [CopyToStg],
                    [SourceQuery],
                    [IsActive],
                    [LastProcessRun],
                    [IncrementColumnName],
                    [IncrementRange],
                    [LastIncrement],
                    [lastmodified])

                SELECT
                    @SystemCode,
                    @SystemName,
                    @lSchema,
                    @lTable,
                    1,
                    1,
                    null,
                    0,
                    null,
                    null,
                    null,
                    null,
                    getdate()
                COMMIT
            END TRY
            BEGIN CATCH
                SET @ErrorMessage = error_message()
                SET @ErrorSeverity = error_severity()
                SET @ErrorState = error_state()
                SET @ErrorLine = error_line()

                RAISERROR(
                    @ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorLine
                )

                ROLLBACK TRANSACTION

            END CATCH
        ELSE
            BEGIN
                IF @TableActive = 0
                    BEGIN
                        BEGIN TRY
                            BEGIN TRANSACTION
                            EXEC(@DeleteTable)
                            INSERT INTO [elt].[MetadataTables]
                            ([SystemCode],
                                [SystemName],
                                [SchemaName],
                                [EntityName],
                                [CopyToRaw],
                                [CopyToStg],
                                [SourceQuery],
                                [IsActive],
                                [LastProcessRun],
                                [IncrementColumnName],
                                [IncrementRange],
                                [LastIncrement],
                                [lastmodified])

                            SELECT
                                @SystemCode,
                                @SystemName,
                                @lSchema,
                                @lTable,
                                [CopyToRaw],
                                [CopyToStg],
                                [SourceQuery],
                                0,
                                [LastProcessRun],
                                [IncrementColumnName],
                                [IncrementRange],
                                [LastIncrement],
                                getdate()
                            FROM #TempMetadataTables
                            COMMIT
                        END TRY

                        BEGIN CATCH
                            SET @ErrorMessage = error_message()
                            SET @ErrorSeverity = error_severity()
                            SET @ErrorState = error_state()
                            SET @ErrorLine = error_line()

                            RAISERROR(
                                @ErrorMessage,
                                @ErrorSeverity,
                                @ErrorState,
                                @ErrorLine
                            )

                            ROLLBACK TRANSACTION

                        END CATCH
                    END
            END
    END
