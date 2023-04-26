CREATE
FUNCTION [elt].[fnCreateStagingFolderPath] (
    @systemname VARCHAR(64),
    @partitiondate DATE
) RETURNS VARCHAR(128) AS
BEGIN
    DECLARE @result VARCHAR(64);

    SET
        @result = CONCAT(
            @systemname, '/', CONVERT(VARCHAR, @partitiondate, 111)
        )
    RETURN @result
END
