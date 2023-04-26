CREATE
FUNCTION [elt].[fnCreateEntityTranslator] (
    @systemname VARCHAR(64),
    @schemaname VARCHAR(50),
    @entityname VARCHAR(64)
) RETURNS VARCHAR(MAX) AS
BEGIN
    DECLARE @result VARCHAR(MAX);

    SELECT @result = CONCAT(
            '{"type":"tabulartranslator","columnmappings":{',
            STRING_AGG(
                CONVERT(VARCHAR(MAX), CONCAT('"', [Name], '":"', [Name], '"')),
                ','
            ) WITHIN GROUP (ORDER BY [OrdinalPosition] ASC),
            ',"ProcessRunId":"ProcessRunId"',
            '}}'
        )
    FROM
        [elt].vwMetaDataRaw
    WHERE
        SYSTEMNAME = @systemname
        AND ENTITYNAME = @entityname
        AND SCHEMANAME = @schemaname


    RETURN @result
END
