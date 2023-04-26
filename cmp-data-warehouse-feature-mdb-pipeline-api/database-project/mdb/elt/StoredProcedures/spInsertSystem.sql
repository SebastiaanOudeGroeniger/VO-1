CREATE PROCEDURE [elt].[spInsertSystem]
    (
        @SystemCode nvarchar(128),
        @SystemName nvarchar(128),
        @SystemType nvarchar(128)
    )
AS

IF NOT EXISTS (SELECT TOP 1 * FROM [elt].[MetadataSystem]
    WHERE 1 = 1
        AND [SystemCode] = @SystemCode
        AND [SystemName] = @SystemName
        AND [SystemType] = @SystemType)
    BEGIN
        INSERT INTO [elt].[MetadataSystem]
        ([SystemCode],
            [SystemName],
            [SystemType],
            [Active],
            [Created])
        VALUES
        (@SystemCode,
            @SystemName,
            @SystemType,
            1,
            GETDATE())
    END
