CREATE PROCEDURE [elt].[spInsertStructureFromView]
    (@Systemcode [nvarchar](128),
        @SystemName [nvarchar](128),
        @SchemaName [nvarchar](128),
        @ViewName [nvarchar](128)

    )

AS

IF EXISTS (SELECT TOP 1 * FROM [elt].[MetadataStructure]
    WHERE EntityName = @ViewName
        AND SchemaName = @SchemaName)
    BEGIN

        DELETE FROM
        [elt].[MetadataStructure]
        WHERE EntityName = @ViewName
            AND SchemaName = @SchemaName

    END



INSERT INTO [elt].[MetadataStructure]
([SystemCode],
    [SystemName],
    [SchemaName],
    [EntityName],
    [Name],
    [DataType],
    [CharacterMaximumLength],
    [IsNullable],
    [OrdinalPosition],
    [NumericPrecision],
    [NumericScale],
    [DatetimeCulture],
    [DatetimeFormat],
    [IsActive],
    [IsPrimaryKey],
    [PrimaryKeyOrdinal],
    [IsHistory],
    [LastModifiedDate],
    [IsDeleted])
SELECT
    @Systemcode,
    @SystemName,
    TABLE_SCHEMA,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE,
    ORDINAL_POSITION,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    DATETIME_PRECISION,
    NULL,
    1,
    0,
    NULL,
    1,
    getdate(),
    0
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @ViewName
    AND TABLE_SCHEMA = @SchemaName
