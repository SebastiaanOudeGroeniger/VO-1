CREATE
FUNCTION [elt].[fnCreateTableName] (
    @schema_name VARCHAR(50),
    @entity_name VARCHAR(64)
) RETURNS NVARCHAR(128) AS
BEGIN

    DECLARE @result NVARCHAR(64);
    SET
        @result = CONCAT(
            QUOTENAME(@schema_name),
            '.',
            QUOTENAME(/*LOWER(REPLACE(*/@entity_name/*, ' ', '_'))*/)
        )

    RETURN @result
END
