CREATE FUNCTION [elt].[fnCreateStagingFileName](
    @entityname VARCHAR(64),
    @schemaname VARCHAR(50),
    @IncrementColumnName NVARCHAR(64),
    @deltadate DATE = NULL,
    @deltarange INT = NULL
)
RETURNS VARCHAR(256)
AS
BEGIN
    DECLARE @result VARCHAR(256);
    SET @result = CASE
        WHEN
            @IncrementColumnName IS NOT NULL /*AND @deltadate IS NOT NULL*/ THEN CONCAT(
                @schemaname, '.', LOWER(@entityname), '_increment', '.parquet'
            )
        --CONCAT(@schemaname, '.', LOWER(@entityname),
        --                                                CASE
        --                                                    WHEN @deltarange > 0
        --                                                    THEN CONCAT('_part_', CONVERT(VARCHAR, @deltadate, 112), '_', CONVERT(VARCHAR, DATEADD(day, @deltarange, @deltadate), 112))
        --                                                    WHEN @deltarange < 0
        --                                                    THEN CONCAT('_part_', CONVERT(VARCHAR, DATEADD(day, @deltarange, @deltadate), 112), '_', CONVERT(VARCHAR, @deltadate, 112))
        --                                                    WHEN @deltarange = 0
        --                                                    THEN CONCAT('_part_', CONVERT(VARCHAR, @deltadate, 112))
        --                                                END, '.parquet')
        ELSE
            CONCAT(@schemaname, '.', LOWER(@entityname), '_full', '.parquet')
        END;
    RETURN @result;
END
