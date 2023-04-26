CREATE FUNCTION [elt].[fnConvertDataTypeOracle](
    @datatype NVARCHAR(128),
    @systemtype NVARCHAR(128),
    @NumericPrecision INT,
    @NumericScale INT,
    @character_maximum_lenght INT
)

RETURNS VARCHAR(256)
AS
BEGIN
    DECLARE @result VARCHAR(256);
    SET @result = (SELECT SinkDataType
        FROM Elt.TypeMap
        WHERE SourceDataType = CASE WHEN @datatype = 'number'
            AND @NumericScale = 0 THEN 'number(' + CAST(@NumericPrecision AS VARCHAR) + ')'
            WHEN
                @datatype = 'number'
                AND @NumericScale = 4
                AND @NumericPrecision = 19 THEN 'number(' + CAST(@NumericPrecision AS VARCHAR) + ',' + CAST(@NumericScale AS VARCHAR) + ')'
            WHEN
                @datatype = 'number'
                AND @NumericScale = 4
                AND @NumericPrecision = 10 THEN 'number(' + CAST(@NumericPrecision AS VARCHAR) + ',' + CAST(@NumericScale AS VARCHAR) + ')'
            WHEN
                @datatype = 'number'
                AND @NumericScale != 0 THEN 'number(10,2)'
            WHEN
                @datatype = 'char'
                AND @character_maximum_lenght = 36 THEN 'char(36)'
            ELSE @datatype END
            AND SystemType = @systemtype
    )
    RETURN @result;
END
