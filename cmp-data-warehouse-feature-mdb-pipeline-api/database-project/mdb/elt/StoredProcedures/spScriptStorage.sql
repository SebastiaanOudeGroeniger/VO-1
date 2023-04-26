CREATE PROCEDURE [elt].[spScriptStorage]
(       @pProject [nvarchar](128)
,		@lSourceSchema [nvarchar](128)
,		@lSourceTable [nvarchar](128)
,		@lStoSchema [nvarchar](128)
,		@lStoTable [nvarchar](128)
,		@SCDType [INT]
,		@lIncrementStaging bit = 0
)
as
begin
        declare @Vcols varchar(max) = '' 
        DECLARE @VSQL VARCHAR(MAX) = ''
        declare @Tcols varchar(max) = ''
		DECLARE	@Cols varchar(Max) = ''
        declare @TSQL varchar(max) = ''
		declare @TSQL2 varchar(max) = ''
		declare @INSQL varchar(max) = ''
		declare @INSQL2 varchar(max) = ''
        declare @STPCols varchar(max) = ''
        declare @STPColsT1 varchar(max) = ''
        declare @STPSQL varchar(max) = ''
        declare @PKs varchar(max) = ''
        declare @PKs2 varchar(max) = ''
        declare @lenPK int = 0
        declare @PBISQL varchar(max) = ''
		declare @TSQLMDDB varchar(max) = ''
		declare @PBISQL1 varchar(max) = ''
        declare @PBICols varchar(max) = ''
        declare @lPBISchema varchar(20) = 'PBI'
		declare @lPBISchemaCurrent varchar(20) = 'PBICur'

        DECLARE @lCR varCHAR(5) = CHAR(13) + CHAR(10)
        DECLARE @CommentBreak CHAR(80) = '--  ----------------------------------------------------------------------------'
        DECLARE @ldat CHAR(8) = CONVERT(CHAR(8),GETDATE(),112)
        DECLARE @lVersion varCHAR(10) = '1.1.0'

        SELECT  @lenPK = 31 + len(@lStoSchema) + len(@lStoTable)
        
        SELECT  @Tcols = @Tcols + ',       [' + C.Name + '] ' +
                CASE S.DATA_TYPE 
                    WHEN 'TINYINT'		THEN    S.DATA_TYPE+' '+ CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
                    WHEN 'SMALLINT'		THEN    S.DATA_TYPE+' '+ CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
                    WHEN 'INT'			THEN    S.DATA_TYPE+' '+ CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
                    WHEN 'BIGINT'		THEN    S.DATA_TYPE+' '+ CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
                    WHEN 'DATETIME'		THEN    S.DATA_TYPE+' '+ CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
                    WHEN 'DATETIME2'	THEN   'DATETIME '+ CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
                    WHEN 'BIT'			THEN     S.DATA_TYPE+' '+ CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
                    WHEN 'DECIMAL'		THEN     S.DATA_TYPE+'('+CAST(S.NUMERIC_PRECISION AS VARCHAR(10))+', '+CAST(S.NUMERIC_SCALE AS VARCHAR(10))+') '+ CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
                    WHEN 'NUMERIC'		THEN     S.DATA_TYPE+'('+CAST(S.NUMERIC_PRECISION AS VARCHAR(10))+', '+CAST(S.NUMERIC_SCALE AS VARCHAR(10))+') '+ CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
                    WHEN 'NVARCHAR'		THEN    'VARCHAR('+ CASE WHEN S.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX) ' ELSE CAST(S.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))+') ' END + CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
                    WHEN 'VARCHAR'		THEN     S.DATA_TYPE+'('+ CASE WHEN S.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX) ' ELSE CAST(S.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))+') ' END + CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
					WHEN 'NCHAR'		THEN    'VARCHAR('+ CASE WHEN S.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX) ' ELSE CAST(S.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))+') ' END + CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
                    WHEN 'CHAR'			THEN     S.DATA_TYPE+'('+ CASE WHEN S.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX) ' ELSE CAST(S.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))+') ' END + CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
                    WHEN 'UNIQUEIDENTIFIER' THEN S.DATA_TYPE+' '+ CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
					WHEN 'DATE' THEN    S.DATA_TYPE+' '+ CASE WHEN S.IS_NULLABLE='NO' THEN 'NOT NULL' ELSE 'NULL' END
                    ELSE '******* DATAYPE? ********'
                END + @lCR
        ,       @PKs = CASE WHEN C.IsPrimaryKey = 1
                                THEN @PKs+replicate(' ', @lenPK)+'AND [T].['+ISNULL(c.[SemanticName],c.[Name])+'] = [V].['+ISNULL(c.[SemanticName],c.[Name])+']' + @lCR
                            ELSE @PKs
                        END 
        ,       @PKs2 = CASE WHEN C.IsPrimaryKey = 1 
                                THEN @PKs2+'        AND     [V].['+ISNULL(c.[SemanticName],c.[Name])+'] IS NULL' + @LCR
                             ELSE @PKs2
                        END
        ,       @STPCols = @STPCols + '        ,       [V].[' + ISNULL(c.[SemanticName],c.[Name]) + ']' + @LCR
        ,       @STPColsT1 = @STPColsT1 + '        ,       [V].[' + c.[Name] + ']' + @LCR
        ,       @PBICols = CASE WHEN C.Name = 'ProcessRunID'
                    THEN @PBICols + ''
                    ELSE @PBICols + ',       [' + C.Name + ']'+@LCR
                 END
        FROM    INFORMATION_SCHEMA.COLUMNS S
        LEFT    JOIN    elt.MetadataStructure C ON S.TABLE_NAME = C.EntityName
											   And S.COLUMN_NAME = C.Name COLLATE Latin1_General_CI_AS
                                               and S.ORDINAL_POSITION = C.OrdinalPosition
        WHERE   1 = 1
        AND     C.EntityName = @lSourceTable
		AND     C.SystemName = @lSourceSchema
        ORDER   BY C.OrdinalPosition
        
        SELECT -- @Tcols = SUBSTRING(@Tcols, 1, len(@Tcols) - 2)        
               @STPCols = '        SELECT  ' + SUBSTRING(@STPCols, 17, LEN(@STPCols) - (17 + 1))
		,	   @STPColsT1 = '        SELECT  ' + SUBSTRING(@STPColsT1, 17, LEN(@STPColsT1) - (17 + 1))
        ,       @PKs = 'ON ' + SUBSTRING(@PKs, @lenPK + 5, LEN(@PKs) - (@lenPK + 6))
        ,       @PKs2 = '        WHERE   '+ SUBSTRING(@PKs2, 17, LEN(@PKs2) - (17 + 1))
       -- ,       @PBICols = SUBSTRING(@PBICols, 1, len(@PBICols) - 2)
------------------------------------------------------------------------------------------------------------------------------------------
/*
Define Columns for Create table script including Datatypes
*/
------------------------------------------------------------------------------------------------------------------------------------------
SELECT @Cols = (Select CONCAT(STRING_AGG(
											CONVERT(varchar(max), CONCAT('['
																		,ISNULL(t.[SemanticName],t.[Name])
																		, ']'
																		, t.[SinkDataType]
																		, CASE
																			WHEN t.[DataType] = 'XML' THEN '' -- Specific exception for XML, the INFORMATION_SCHEMA.COLUMNS gets the value -1 for CharacterMaximumLength but if this is used when creating the table you get an error.
																			WHEN t.[CharacterMaximumLength] = -1 THEN '(MAX)'
																			WHEN t.[DataType] = 'decimal' then Concat('(',[NumericPrecision],',',[NumericScale],')')
																			WHEN t.[DataType] = 'numeric' then Concat('(',[NumericPrecision],',',[NumericScale],')')
																			WHEN t.[CharacterMaximumLength] IS NULL THEN ''
																			ELSE CONCAT('(',  t.[CharacterMaximumLength], ')')
																		END
																		, ' '
																		, IIF(t.[IsNullable] = 'NO', 'NOT NULL', 'NULL')
																  )
											)
										, '
,       '
										  ) WITHIN GROUP (ORDER BY t.[OrdinalPosition] ASC)
										  , ''
										  )
			FROM [elt].[vwMetaDataRaw] t
			WHERE 1=1
			AND [elt].[fnCreateTableName](t.SystemName, t.EntityName) = [elt].[fnCreateTableName](@lSourceSchema, @lSourceTable))
------------------------------------------------------------------------------------------------------------------------------------------
/*
Create Temptable to compare Raw/staging with Storage
*/
------------------------------------------------------------------------------------------------------------------------------------------
SELECT  @TSQL2 = ''
        ,       @TSQL2 = @TSQL2 + @lCR + @CommentBreak
        ,       @TSQL2 = @TSQL2 + @lCR + '--  Script for TempTable ['+@lStoSchema+'].[' +@lStoTable+ ']'
        ,       @TSQL2 = @TSQL2 + @lCR + @CommentBreak
		,       @TSQL2 = @TSQL2 + @lCR + 'IF OBJECT_ID(N' + '''' + 'tempdb..#TEMP' + @lStoTable + '''' + ') IS NOT NULL'
		,       @TSQL2 = @TSQL2 + @lCR + 'BEGIN '
		,       @TSQL2 = @TSQL2 + @lCR + 'DROP TABLE #TEMP'+@lStoTable
		,       @TSQL2 = @TSQL2 + @lCR + 'END'			 
		,       @TSQL2 = @TSQL2 + @lCR + 'CREATE  TABLE #TEMP'+@lStoTable
		,       @TSQL2 = @TSQL2 + @lCR +  '('
		,		@TSQL2 = @TSQL2 + @lCR + @Cols
	    ,       @TSQL2 = @TSQL2 + @lCR + ',       [Hash] VARBINARY(8000) NOT NULL'
        ,       @TSQL2 = @TSQL2 + @lCR + ',       [Current] BIT NOT NULL'
        ,       @TSQL2 = @TSQL2 + @lCR + ',       [isDeleted] BIT NOT NULL'
        ,       @TSQL2 = @TSQL2 + @lCR + ',       [StartDate] DATETIME NOT NULL'
        ,       @TSQL2 = @TSQL2 + @lCR + ',       [EndDate] DATETIME NOT NULL DEFAULT ''99991231'''
        ,       @TSQL2 = @TSQL2 + @lCR + ',       [ProcessRunID] INT NOT NULL'
        ,       @TSQL2 = @TSQL2 + @lCR + ')'
        ,       @TSQL2 = @TSQL2 + @lCR + ''

------------------------------------------------------------------------------------------------------------------------------------------
/*
Build Hash
*/
------------------------------------------------------------------------------------------------------------------------------------------

        declare @Vcols2 varchar(max) = ''

        select  @Vcols2 = CASE WHEN T.[Name] = 'CompanyID'
                            THEN @Vcols2
                            ELSE 
                                CASE WHEN ISNULL(M.IsPrimaryKey, 0) = 0
                                    THEN @Vcols2 + '        +   ''|'' + ' +
                                            CASE WHEN C.IS_NULLABLE = 'YES'
                                                THEN CASE C.DATA_TYPE
                                                    WHEN 'TINYINT' THEN 'ISNULL(CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(4)),CAST(1 AS VARCHAR(1)))'
                                                    WHEN 'SMALLINT' THEN 'ISNULL(CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(6)),CAST(1 AS VARCHAR(1)))'
                                                    WHEN 'INT' THEN 'ISNULL(CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(11)),CAST(1 AS VARCHAR(1)))'
                                                    WHEN 'BIGINT' THEN 'ISNULL(CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(21)),CAST(1 AS VARCHAR(1)))'
                                                    WHEN 'BIT' THEN 'ISNULL(CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(1)),CAST(1 AS VARCHAR(1)))'
                                                    WHEN 'DATETIME' THEN 'ISNULL(CONVERT(VARCHAR(19), [' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '], 120),CAST(1 AS VARCHAR(1)))'
                                                    WHEN 'DATETIME2' THEN 'ISNULL(CONVERT(VARCHAR(19), [' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '], 120),CAST(1 AS VARCHAR(1)))'
                                                    WHEN 'DECIMAL' THEN 'ISNULL(CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(' + CAST(C.NUMERIC_PRECISION + 2 AS VARCHAR(10)) + ')),CAST(1 AS VARCHAR(1)))'
													WHEN 'FLOAT' THEN 'ISNULL(CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(' + CAST(C.NUMERIC_PRECISION + 2 AS VARCHAR(10)) + ')),CAST(1 AS VARCHAR(1)))'
                                                    WHEN 'NUMERIC' THEN 'ISNULL(CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(' + CAST(C.NUMERIC_PRECISION + 2 AS VARCHAR(10)) + ')),CAST(1 AS VARCHAR(1)))'
                                                    WHEN 'NVARCHAR' THEN 'ISNULL([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '],CAST(1 AS VARCHAR(1)))'
                                                    WHEN 'VARCHAR' THEN 'ISNULL([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '],CAST(1 AS VARCHAR(1)))'
													WHEN 'NCHAR' THEN 'ISNULL([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '],CAST(1 AS VARCHAR(1)))'
                                                    WHEN 'CHAR' THEN 'ISNULL([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '],CAST(1 AS VARCHAR(1)))'
                                                    WHEN 'UNIQUEIDENTIFIER' THEN 'ISNULL(CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(255)),CAST(1 AS VARCHAR(1)))'
													WHEN 'DATE' THEN 'ISNULL(CONVERT(VARCHAR(19), [' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '], 120),CAST(1 AS VARCHAR(1)))'
													WHEN 'varbinary' THEN 'ISNULL(CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(max)),CAST(1 AS VARCHAR(1)))'
													WHEN 'Money' THEN 'ISNULL(CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(30)),CAST(1 AS VARCHAR(1)))'
                                                    ELSE '*** [' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] ***'
                                                     END + char(13) + char(10) 
                                            ELSE CASE C.DATA_TYPE
                                                    WHEN 'TINYINT' THEN 'CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(4))'
                                                    WHEN 'SMALLINT' THEN 'CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(6))'
                                                    WHEN 'INT' THEN 'CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(11))'
                                                    WHEN 'BIGINT' THEN 'CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(21))'
                                                    WHEN 'BIT' THEN 'CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(1))'
                                                    WHEN 'DATETIME' THEN 'CONVERT(VARCHAR(19), [' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '], 120)'
                                                    WHEN 'DATETIME2' THEN 'CONVERT(VARCHAR(19), [' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '], 120)'
                                                    WHEN 'DECIMAL' THEN 'CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(' + CAST(C.NUMERIC_PRECISION + 2 AS VARCHAR(10)) + '))'
                                                    WHEN 'FLOAT' THEN 'CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(' + CAST(C.NUMERIC_PRECISION + 2 AS VARCHAR(10)) + '))'
                                                    WHEN 'NUMERIC' THEN 'CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(' + CAST(C.NUMERIC_PRECISION + 2 AS VARCHAR(10)) + '))'
                                                    WHEN 'NVARCHAR' THEN '[' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + ']'
                                                    WHEN 'VARCHAR' THEN '[' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + ']'
                                                    WHEN 'NCHAR' THEN '[' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + ']'
                                                    WHEN 'CHAR' THEN '[' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + ']'
                                                    WHEN 'UNIQUEIDENTIFIER' THEN '[' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + ']'
													WHEN 'DATE' THEN 'CONVERT(VARCHAR(19), [' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '], 120)'
													WHEN 'varbinary' THEN 'ISNULL(CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(max)),CAST(1 AS VARCHAR(1)))'
													WHEN 'Money' THEN 'ISNULL(CAST([' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] AS VARCHAR(30)),CAST(1 AS VARCHAR(1)))'
                                                    ELSE '*** [' + ISNULL(M.[Name], '***'+C.COLUMN_NAME+'***') + '] ***'
                                                 END + char(13) + char(10) 
                                            END
                                    ELSE @Vcols2 + ''
                                END 
                            END    
        from    elt.[vwMetaDataRaw] T
        left    join    INFORMATION_SCHEMA.COLUMNS C ON T.EntityName = C.TABLE_NAME COLLATE Latin1_General_CI_AS 
                                                            AND T.OrdinalPosition = C.ORDINAL_POSITION
		LEFT JOIN elt.MetadataStructure  M ON M.EntityName = T.EntityName
										AND M.SchemaName = T.SchemaName
										AND M.Name = T.Name

        where   1 = 1
        and     M.IsActive = 1
		and		M.IsHistory = 1
        and     T.EntityName  = @lSourceTable
		AND		T.SystemName = @lSourceSchema

DECLARE @Hash varchar(max)

		Set @Hash =  ',       HASHBYTES(''MD5'', ''''' + char(13) + char(10) + @Vcols2 + '        ) AS [Hash]'
------------------------------------------------------------------------------------------------------------------------------------------
/*
Define Columns in Insert Statement
*/
------------------------------------------------------------------------------------------------------------------------------------------

Set @INSQL2 =
			(
			SelecT STRING_AGG(CONVERT(varchar(max), CONCAT('[',t.[Name], ']'))
													  , '
,'
													  ) WITHIN GROUP (ORDER BY t.[OrdinalPosition] ASC)
					+''
					FROM [elt].[vwMetaDataRaw] t
					where 1 = 1
					and EntityName = @lSourceTable 
					AND SystemName = @lSourceSchema
			)
------------------------------------------------------------------------------------------------------------------------------------------
/*
INSERT INTO Script for Temp table (reused in STP)
*/
------------------------------------------------------------------------------------------------------------------------------------------
SELECT @INSQL = '' 
        ,       @INSQL = @INSQL + @lCR + @CommentBreak
        ,       @INSQL = @INSQL + @lCR + '--  Script for INSERT INTO #TEMP'+@lStoTable
        ,       @INSQL = @INSQL + @lCR + @CommentBreak
		,       @INSQL = @INSQL + @lCR + 'INSERT INTO #TEMP'+@lStoTable
		,       @INSQL = @INSQL + @lCR +  'SELECT'
		,		@INSQL = @INSQL + @lCR + @INSQL2
	    ,       @INSQL = @INSQL + @lCR + @Hash
        ,       @INSQL = @INSQL + @lCR + ',1'
        ,       @INSQL = @INSQL + @lCR + ',0'
        ,       @INSQL = @INSQL + @lCR + ',GETDATE()'
        ,       @INSQL = @INSQL + @lCR + ',''99991231'''
        ,       @INSQL = @INSQL + @lCR + ',@ProcessRunID'
        ,       @INSQL = @INSQL + @lCR + 'From ' + [elt].[fnCreateTableName](@lSourceSchema, @lSourceTable)
        ,       @INSQL = @INSQL + @lCR + ''

------------------------------------------------------------------------------------------------------------------------------------------
/*
Create Storage Table script for DWH
*/
------------------------------------------------------------------------------------------------------------------------------------------
SELECT  @TSQL = ''
        ,       @TSQL = @TSQL + @lCR + @CommentBreak
        ,       @TSQL = @TSQL + @lCR + '--  Script for ['+@lStoSchema+'].[' +@lStoTable+ ']'
        ,       @TSQL = @TSQL + @lCR + @CommentBreak
		,       @TSQL = @TSQL + @lCR +		'IF OBJECT_ID('+ '''' +@lStoSchema+ '.' + @lStoTable + '''' + ', ''' + 'u''' + ') IS NOT NULL' 
		,       @TSQL = @TSQL + @lCR +		'DROP TABLE'+ '['+@lStoSchema+'].['+@lStoTable+']'


		,       @TSQL = @TSQL + @lCR + 'CREATE  TABLE ['+@lStoSchema+'].['+@lStoTable+']'
		,       @TSQL = @TSQL + @lCR +  '( [SCD'+@lStoTable+'Key] INT NOT NULL IDENTITY (1,1),'
		,		@TSQL = @TSQL + @lCR + @Cols
	    ,       @TSQL = @TSQL + @lCR + ',       [Hash] VARBINARY(8000) NOT NULL'
        ,       @TSQL = @TSQL + @lCR + ',       [Current] BIT NOT NULL'
        ,       @TSQL = @TSQL + @lCR + ',       [isDeleted] BIT NOT NULL'
        ,       @TSQL = @TSQL + @lCR + ',       [StartDate] DATETIME NOT NULL'
        ,       @TSQL = @TSQL + @lCR + ',       [EndDate] DATETIME NOT NULL DEFAULT ''99991231'''
        ,       @TSQL = @TSQL + @lCR + ',       [ProcessRunID] INT NOT NULL'
        ,       @TSQL = @TSQL + @lCR + ')'
        ,       @TSQL = @TSQL + @lCR + 'GO'
        ,       @TSQL = @TSQL + @lCR + '' 
------------------------------------------------------------------------------------------------------------------------------------------
/*
Create Storage Table script for MDDB
*/
------------------------------------------------------------------------------------------------------------------------------------------
SELECT  @TSQLMDDB = ''
        ,       @TSQLMDDB = @TSQLMDDB + @lCR + @CommentBreak
        ,       @TSQLMDDB = @TSQLMDDB + @lCR + '--  Script for ['+@lStoSchema+'].[' +@lStoTable+ ']'
        ,       @TSQLMDDB = @TSQLMDDB + @lCR + @CommentBreak
		,       @TSQLMDDB = @TSQLMDDB + @lCR +		'IF OBJECT_ID('+ '''' +@lStoSchema+ '.' + @lStoTable + '''' + ', ''' + 'u''' + ') IS NOT NULL' 
		,       @TSQLMDDB = @TSQLMDDB + @lCR +		'DROP TABLE'+ '['+@lStoSchema+'].['+@lStoTable+']
		
		'
		,       @TSQLMDDB = @TSQLMDDB + @lCR + 'CREATE  TABLE ['+@lStoSchema+'].['+@lStoTable+']'
		,       @TSQLMDDB = @TSQLMDDB + @lCR +  '( [SCD'+@lStoTable+'Key] INT NOT NULL IDENTITY (1,1),'
		,		@TSQLMDDB = @TSQLMDDB + @lCR + @Cols
	    ,       @TSQLMDDB = @TSQLMDDB + @lCR + ',       [Hash] VARBINARY(8000) NOT NULL'
        ,       @TSQLMDDB = @TSQLMDDB + @lCR + ',       [Current] BIT NOT NULL'
        ,       @TSQLMDDB = @TSQLMDDB + @lCR + ',       [isDeleted] BIT NOT NULL'
        ,       @TSQLMDDB = @TSQLMDDB + @lCR + ',       [StartDate] DATETIME NOT NULL'
        ,       @TSQLMDDB = @TSQLMDDB + @lCR + ',       [EndDate] DATETIME NOT NULL DEFAULT ''99991231'''
        ,       @TSQLMDDB = @TSQLMDDB + @lCR + ',       [ProcessRunID] INT NOT NULL'
        ,       @TSQLMDDB = @TSQLMDDB + @lCR + ')'
        ,       @TSQLMDDB = @TSQLMDDB + @lCR + '' 
------------------------------------------------------------------------------------------------------------------------------------------
/*
Create Stored Procedure that builds SCD type 2 history in Storage layer
*/
------------------------------------------------------------------------------------------------------------------------------------------
 IF @SCDType = 2 AND @lIncrementStaging = 0
	BEGIN
	 
        SELECT  @STPSQL = ''
        ,       @STPSQL = @STPSQL + @lCR +'IF OBJECT_ID('+ '''' +@lStoSchema+ '.Load' + @lStoTable + '''' + ') IS NOT NULL' 
        ,       @STPSQL = @STPSQL + @lCR +'DROP PROCEDURE'+ '['+@lStoSchema+'].[Load'+@lStoTable+']'
        ,       @STPSQL = @STPSQL + @lCR +'GO'
        ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
        ,       @STPSQL = @STPSQL + @lCR + '--  Script for ['+@lStoSchema+'].[Load'+@lStoTable+']'
        ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
        ,       @STPSQL = @STPSQL + @lCR + '--  '+@ldat+' Generator ' + @lVersion + ' for ' + @pProject + ' project'
        ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
        ,       @STPSQL = @STPSQL + @lCR + 'CREATE  PROCEDURE ['+@lStoSchema+'].[Load'+@lStoTable+']'
        ,       @STPSQL = @STPSQL + @lCR + '        @ProcessRunID      INT'
        ,       @STPSQL = @STPSQL + @lCR + ',       @PipelineRunID      uniqueidentifier'
        ,       @STPSQL = @STPSQL + @lCR + ',       @TaskName           VARCHAR(100)'
        ,       @STPSQL = @STPSQL + @lCR + ',       @Schema				VARCHAR(100)'
        ,       @STPSQL = @STPSQL + @lCR + ',       @EntityName         VARCHAR(100)'
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + 'AS'
        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN'
        ,       @STPSQL = @STPSQL + @lCR + 'DECLARE @InputInsertedRows       INT = 0'
        ,       @STPSQL = @STPSQL + @lCR + ',       @InputUpdatedRows         INT = 0'
        ,       @STPSQL = @STPSQL + @lCR + ',       @InputDeletedRows        INT = 0'
        ,       @STPSQL = @STPSQL + @lCR + ',       @ErrorCode          INT = 0'
        ,       @STPSQL = @STPSQL + @lCR + ',       @ErrorDescription   VARCHAR(MAX)'
        ,       @STPSQL = @STPSQL + @lCR + ',       @Nu                 DATETIME '
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + 'IF EXISTS (SELECT 1 FROM ['+@lStoSchema+'].['+@lStoTable+'] WHERE [SCD'+@lStoTable+'Key] > 0)'
        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN'
        ,       @STPSQL = @STPSQL + @lCR + '        SELECT @Nu = GETDATE()'
        ,       @STPSQL = @STPSQL + @lCR + 'END'
        ,       @STPSQL = @STPSQL + @lCR + 'ELSE'
        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN'
        ,       @STPSQL = @STPSQL + @lCR + '        SELECT @Nu = ''19000101'''
        ,       @STPSQL = @STPSQL + @lCR + 'END '
        ,       @STPSQL = @STPSQL + @lCR + ' '
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN TRY  '
        ,       @STPSQL = @STPSQL + @lCR + '        BEGIN TRANSACTION'
        ,       @STPSQL = @STPSQL + @lCR + @TSQL2
		,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + @INSQL
		,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '        --  Stored Procedure'
        ,       @STPSQL = @STPSQL + @lCR + '        --  Update mutated records, Set Enddate and Current = 0'
        ,       @STPSQL = @STPSQL + @lCR + '        UPDATE  ['+@lStoSchema+'].['+@lStoTable+']'
        ,       @STPSQL = @STPSQL + @lCR + '        SET     [EndDate] = @Nu'
        ,       @STPSQL = @STPSQL + @lCR + '        ,       [ProcessRunID] = @ProcessRunID'
        ,       @STPSQL = @STPSQL + @lCR + '        ,       [Current] = 0'
        ,       @STPSQL = @STPSQL + @lCR + '        FROM    [#TEMP'+@lStoTable+'] V'
        ,       @STPSQL = @STPSQL + @lCR + '        LEFT    JOIN    ['+@lStoSchema+'].['+@lStoTable+'] T ' + @PKs
        ,       @STPSQL = @STPSQL + @lCR + replicate (' ', @lenPK)
        ,       @STPSQL = @STPSQL + @lCR + '        WHERE   [V].[Hash] != [T].[Hash]'
        ,       @STPSQL = @STPSQL + @lCR + '        AND     [T].[EndDate] = ''29991231'''
        ,       @STPSQL = @STPSQL + @lCR + '        SELECT  @InputUpdatedRows = @@ROWCOUNT'
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '        -- Update removed records, Set Enddate, Current = 0 and isDeleted = 1'
        ,       @STPSQL = @STPSQL + @lCR + '        UPDATE  ['+@lStoSchema+'].['+@lStoTable+']'
        ,       @STPSQL = @STPSQL + @lCR + '        SET     [EndDate] = @Nu'
        ,       @STPSQL = @STPSQL + @lCR + '        ,       [ProcessRunID] = @ProcessRunID'
        ,       @STPSQL = @STPSQL + @lCR + '        ,       [Current] = 0'
        ,       @STPSQL = @STPSQL + @lCR + '        ,       [isDeleted] = 1'
        ,       @STPSQL = @STPSQL + @lCR + '        FROM    [#TEMP'+@lStoTable+'] V'
        ,       @STPSQL = @STPSQL + @lCR + '        RIGHT   JOIN    ['+@lStoSchema+'].['+@lStoTable+'] T '+@PKs
        ,       @STPSQL = @STPSQL + @lCR + replicate (' ', @lenPK)
        ,       @STPSQL = @STPSQL + @lCR + @PKs2
        ,       @STPSQL = @STPSQL + @lCR + '        AND     [T].[EndDate] = ''29991231'''
        ,       @STPSQL = @STPSQL + @lCR + '        SELECT  @InputDeletedRows = @@ROWCOUNT'
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '        --  Insert New records or New versions of records'
        ,       @STPSQL = @STPSQL + @lCR + '        INSERT  INTO ['+@lStoSchema+'].['+@lStoTable+']'
		,       @STPSQL = @STPSQL + @lCR + '('
		,       @STPSQL = @STPSQL + @lCR + REPLACE(Replace(@STPCols,'Select',''),'[V].','')
		,       @STPSQL = @STPSQL + @lCR + '		,       [Hash]'
		,       @STPSQL = @STPSQL + @lCR + '		,       [Current]'
		,       @STPSQL = @STPSQL + @lCR + '		,       [isDeleted]'
		,       @STPSQL = @STPSQL + @lCR + '		,       [StartDate]'
		,       @STPSQL = @STPSQL + @lCR + '		,       [EndDate]'
		,       @STPSQL = @STPSQL + @lCR + '		,       [ProcessRunID]'
		,       @STPSQL = @STPSQL + @lCR + ')'
        ,       @STPSQL = @STPSQL + @lCR + @STPCols
        ,       @STPSQL = @STPSQL + @lCR +'        ,       [V].[Hash]'
        ,       @STPSQL = @STPSQL + @lCR +'        ,       1' 
        ,       @STPSQL = @STPSQL + @lCR +'        ,       0' 
        ,       @STPSQL = @STPSQL + @lCR +'        ,       @Nu' 
        ,       @STPSQL = @STPSQL + @lCR +'        ,       ''29991231'''
        ,       @STPSQL = @STPSQL + @lCR + '        ,       @ProcessRunID'
        ,       @STPSQL = @STPSQL + @lCR + '        FROM    [#TEMP'+@lStoTable+'] V'
        ,       @STPSQL = @STPSQL + @lCR + '        LEFT    JOIN    ['+@lStoSchema+'].['+@lStoTable+'] T '+@PKs
        ,       @STPSQL = @STPSQL + @lCR + replicate (' ', @lenPK)
        ,       @STPSQL = @STPSQL + @lCR + '        WHERE   (([T].[SCD'+@lStoTable+'Key] IS NULL) '
        ,       @STPSQL = @STPSQL + @lCR + '                OR      ([V].[Hash] != [T].[Hash]))'
        ,       @STPSQL = @STPSQL + @lCR + '        AND     ISNULL([T].ProcessRunID, @ProcessRunID) = @ProcessRunID'
        ,       @STPSQL = @STPSQL + @lCR + '        SELECT @InputInsertedRows = @@ROWCOUNT'
        ,       @STPSQL = @STPSQL + @lCR + '        '
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '  		-- Set Removed Records back to Current if record resurfaces'
        ,       @STPSQL = @STPSQL + @lCR + '        UPDATE  ['+@lStoSchema+'].['+@lStoTable+']'
        ,       @STPSQL = @STPSQL + @lCR + '		SET     [EndDate] = ''29991231'''
        ,       @STPSQL = @STPSQL + @lCR + '		,       [ProcessRunID] = @ProcessRunID'
        ,       @STPSQL = @STPSQL + @lCR + '		,       [Current] = 1'
        ,       @STPSQL = @STPSQL + @lCR + '		,		[isDeleted] = 0'
        ,       @STPSQL = @STPSQL + @lCR + '        FROM    [#TEMP'+@lStoTable+'] V'
        ,       @STPSQL = @STPSQL + @lCR + '        RIGHT    JOIN    ['+@lStoSchema+'].['+@lStoTable+'] T '+@PKs
        ,       @STPSQL = @STPSQL + @lCR + '		WHERE   [T].[isDeleted] = 1'
        ,       @STPSQL = @STPSQL + @lCR + '		AND		[T].[Hash] = [V].[Hash]'
        ,       @STPSQL = @STPSQL + @lCR + '		AND		[T].[EndDate] != ''29991231''' 
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '        COMMIT'
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '        --  Audit Data Processing'
        ,       @STPSQL = @STPSQL + @lCR + '       EXECUTE [audit].[spInsertDataLogStorage] '
        ,       @STPSQL = @STPSQL + @lCR + '          @process_run_id = @ProcessRunID'
        ,       @STPSQL = @STPSQL + @lCR + '         ,@pipeline_run_id = @PipelineRunID'
        ,       @STPSQL = @STPSQL + @lCR + '         ,@schema = @Schema'
		,       @STPSQL = @STPSQL + @lCR + '         ,@entity_name = @EntityName'
        ,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_insert = @InputInsertedRows'
        ,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_update = @InputUpdatedRows'
        ,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_delete = @InputDeletedRows'    
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + 'END TRY  '
        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN CATCH  '
        ,       @STPSQL = @STPSQL + @lCR + '        SELECT  @ErrorCode = ERROR_NUMBER()'
        ,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_SEVERITY() AS ErrorSeverity  '
        ,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_STATE() AS ErrorState  '
        ,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_PROCEDURE() AS ErrorProcedure  '
        ,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_LINE() AS ErrorLine  '
        ,       @STPSQL = @STPSQL + @lCR + '        ,       @ErrorDescription = ERROR_MESSAGE();  '
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '        IF @@TRANCOUNT > 0  '
        ,       @STPSQL = @STPSQL + @lCR + '        BEGIN'
        ,       @STPSQL = @STPSQL + @lCR + '                ROLLBACK TRANSACTION; '
        ,       @STPSQL = @STPSQL + @lCR + '        END'
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '        --  Audit Fout'
        ,       @STPSQL = @STPSQL + @lCR + '		EXECUTE [audit].[spErrorLog]'
        ,       @STPSQL = @STPSQL + @lCR + '		   @ProcessID    = @ProcessRunID'
        ,       @STPSQL = @STPSQL + @lCR + '		  ,@Schema		 = @Schema'
        ,       @STPSQL = @STPSQL + @lCR + '		  ,@EntityName   = @EntityName'
        ,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorCode    = @ErrorCode'
        ,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorDescription = @ErrorDescription '
		,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorType = '+ ''''+ ''''+ ''
		,       @STPSQL = @STPSQL + @lCR + '		   ;'
		,       @STPSQL = @STPSQL + @lCR + '-- Return Error'
		,       @STPSQL = @STPSQL + @lCR + 'THROW'
		,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + 'END CATCH  '
        ,       @STPSQL = @STPSQL + @lCR + ''
		,		@STPSQL = @STPSQL + @lCR + '		SELECT'
		,		@STPSQL = @STPSQL + @lCR + '		@ProcessRunID		AS	 ProcessRunID'
		,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lSourceSchema+'''' + 'AS [SourceSchema]'
		,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lSourceTable+''''	+ 'AS [SourceTable]'
		,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lStoSchema+'''' + 'AS [SinkSchema]'
		,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lStoTable+''''	+ 'AS [SinkTable]'
		,		@STPSQL = @STPSQL + @lCR + '		,@TaskName		AS	 TaskName'
		,		@STPSQL = @STPSQL + @lCR + '		,@InputInsertedRows	AS	RowsWritten'
		,		@STPSQL = @STPSQL + @lCR + '		,@InputUpdatedRows 	AS	RowsUpdated'
		,		@STPSQL = @STPSQL + @lCR + '		,@InputDeletedRows 	AS	RowsDeleted'
		,		@STPSQL = @STPSQL + @lCR + '		,@ErrorDescription	AS ErrorDescription'
		,		@STPSQL = @STPSQL + @lCR + '		,@ErrorCode       	AS ErrorCode'
        ,       @STPSQL = @STPSQL + @lCR + 'END'
        ,       @STPSQL = @STPSQL + @lCR + 'GO'
        ,       @STPSQL = @STPSQL + @lCR + ''
	END

------------------------------------------------------------------------------------------------------------------------------------------
/*
Create Stored Procedure that builds SCD type 2 history in Storage layer AND Staging is Incremental
*/
------------------------------------------------------------------------------------------------------------------------------------------
 IF @SCDType = 2 AND @lIncrementStaging = 1
	BEGIN
	 
        SELECT  @STPSQL = ''
        ,       @STPSQL = @STPSQL + @lCR +'IF OBJECT_ID('+ '''' +@lStoSchema+ '.Load' + @lStoTable + '''' + ') IS NOT NULL' 
        ,       @STPSQL = @STPSQL + @lCR +'DROP PROCEDURE'+ '['+@lStoSchema+'].[Load'+@lStoTable+']'
        ,       @STPSQL = @STPSQL + @lCR +'GO'
        ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
        ,       @STPSQL = @STPSQL + @lCR + '--  Script for ['+@lStoSchema+'].[Load'+@lStoTable+']'
        ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
        ,       @STPSQL = @STPSQL + @lCR + '--  '+@ldat+' Generator ' + @lVersion + ' for ' + @pProject + ' project'
        ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
        ,       @STPSQL = @STPSQL + @lCR + 'CREATE  PROCEDURE ['+@lStoSchema+'].[Load'+@lStoTable+']'

        ,       @STPSQL = @STPSQL + @lCR + '        @ProcessRunID      INT'
        ,       @STPSQL = @STPSQL + @lCR + ',       @PipelineRunID      uniqueidentifier'
        ,       @STPSQL = @STPSQL + @lCR + ',       @TaskName           VARCHAR(100)'
        ,       @STPSQL = @STPSQL + @lCR + ',       @Schema				VARCHAR(100)'
        ,       @STPSQL = @STPSQL + @lCR + ',       @EntityName         VARCHAR(100)'
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + 'AS'
        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN'
        ,       @STPSQL = @STPSQL + @lCR + 'DECLARE @InputInsertedRows       INT = 0'
        ,       @STPSQL = @STPSQL + @lCR + ',       @InputUpdatedRows         INT = 0'
        ,       @STPSQL = @STPSQL + @lCR + ',       @InputDeletedRows        INT = 0'
        ,       @STPSQL = @STPSQL + @lCR + ',       @ErrorCode          INT = 0'
        ,       @STPSQL = @STPSQL + @lCR + ',       @ErrorDescription   VARCHAR(MAX)'
        ,       @STPSQL = @STPSQL + @lCR + ',       @Nu                 DATETIME '
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + 'IF EXISTS (SELECT 1 FROM ['+@lStoSchema+'].['+@lStoTable+'] WHERE [SCD'+@lStoTable+'Key] > 0)'
        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN'
        ,       @STPSQL = @STPSQL + @lCR + '        SELECT @Nu = GETDATE()'
        ,       @STPSQL = @STPSQL + @lCR + 'END'
        ,       @STPSQL = @STPSQL + @lCR + 'ELSE'
        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN'
        ,       @STPSQL = @STPSQL + @lCR + '        SELECT @Nu = ''19000101'''
        ,       @STPSQL = @STPSQL + @lCR + 'END '
        ,       @STPSQL = @STPSQL + @lCR + ' '
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN TRY  '
        ,       @STPSQL = @STPSQL + @lCR + '        BEGIN TRANSACTION'
        ,       @STPSQL = @STPSQL + @lCR + @TSQL2
		,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + @INSQL
		,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '        --  Stored Procedure'
        ,       @STPSQL = @STPSQL + @lCR + '        --  Update mutated records, Set Enddate and Current = 0'
        ,       @STPSQL = @STPSQL + @lCR + '        UPDATE  ['+@lStoSchema+'].['+@lStoTable+']'
        ,       @STPSQL = @STPSQL + @lCR + '        SET     [EndDate] = @Nu'
        ,       @STPSQL = @STPSQL + @lCR + '        ,       [ProcessRunID] = @ProcessRunID'
        ,       @STPSQL = @STPSQL + @lCR + '        ,       [Current] = 0'
        ,       @STPSQL = @STPSQL + @lCR + '        FROM    [#TEMP'+@lStoTable+'] V'
        ,       @STPSQL = @STPSQL + @lCR + '        LEFT    JOIN    ['+@lStoSchema+'].['+@lStoTable+'] T ' + @PKs
        ,       @STPSQL = @STPSQL + @lCR + replicate (' ', @lenPK)
        ,       @STPSQL = @STPSQL + @lCR + '        WHERE   [V].[Hash] != [T].[Hash]'
        ,       @STPSQL = @STPSQL + @lCR + '        AND     [T].[EndDate] = ''29991231'''
        ,       @STPSQL = @STPSQL + @lCR + '        SELECT  @InputUpdatedRows = @@ROWCOUNT'
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '        --  Insert New records or New versions of records'
        ,       @STPSQL = @STPSQL + @lCR + '        INSERT  INTO ['+@lStoSchema+'].['+@lStoTable+']'
		,       @STPSQL = @STPSQL + @lCR + '('
		,       @STPSQL = @STPSQL + @lCR + REPLACE(Replace(@STPCols,'Select',''),'[V].','')
		,       @STPSQL = @STPSQL + @lCR + '		,       [Hash]'
		,       @STPSQL = @STPSQL + @lCR + '		,       [Current]'
		,       @STPSQL = @STPSQL + @lCR + '		,       [isDeleted]'
		,       @STPSQL = @STPSQL + @lCR + '		,       [StartDate]'
		,       @STPSQL = @STPSQL + @lCR + '		,       [EndDate]'
		,       @STPSQL = @STPSQL + @lCR + '		,       [ProcessRunID]'
		,       @STPSQL = @STPSQL + @lCR + ')'
        ,       @STPSQL = @STPSQL + @lCR + @STPCols
        ,       @STPSQL = @STPSQL + @lCR +'        ,       [V].[Hash]'
        ,       @STPSQL = @STPSQL + @lCR +'        ,       1' 
        ,       @STPSQL = @STPSQL + @lCR +'        ,       0' 
        ,       @STPSQL = @STPSQL + @lCR +'        ,       @Nu' 
        ,       @STPSQL = @STPSQL + @lCR +'        ,       ''29991231'''
        ,       @STPSQL = @STPSQL + @lCR + '        ,       @ProcessRunID'
        ,       @STPSQL = @STPSQL + @lCR + '        FROM    [#TEMP'+@lStoTable+'] V'
        ,       @STPSQL = @STPSQL + @lCR + '        LEFT    JOIN    ['+@lStoSchema+'].['+@lStoTable+'] T '+@PKs
        ,       @STPSQL = @STPSQL + @lCR + replicate (' ', @lenPK)
        ,       @STPSQL = @STPSQL + @lCR + '        WHERE   (([T].[SCD'+@lStoTable+'Key] IS NULL) '
        ,       @STPSQL = @STPSQL + @lCR + '                OR      ([V].[Hash] != [T].[Hash]))'
        ,       @STPSQL = @STPSQL + @lCR + '        AND     ISNULL([T].ProcessRunID, @ProcessRunID) = @ProcessRunID'
        ,       @STPSQL = @STPSQL + @lCR + '        SELECT @InputInsertedRows = @@ROWCOUNT'
        ,       @STPSQL = @STPSQL + @lCR + '        '
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '  		-- Set Removed Records back to Current if record resurfaces'
        ,       @STPSQL = @STPSQL + @lCR + '        UPDATE  ['+@lStoSchema+'].['+@lStoTable+']'
        ,       @STPSQL = @STPSQL + @lCR + '		SET     [EndDate] = ''29991231'''
        ,       @STPSQL = @STPSQL + @lCR + '		,       [ProcessRunID] = @ProcessRunID'
        ,       @STPSQL = @STPSQL + @lCR + '		,       [Current] = 1'
        ,       @STPSQL = @STPSQL + @lCR + '		,		[isDeleted] = 0'
        ,       @STPSQL = @STPSQL + @lCR + '        FROM    [#TEMP'+@lStoTable+'] V'
        ,       @STPSQL = @STPSQL + @lCR + '        RIGHT    JOIN    ['+@lStoSchema+'].['+@lStoTable+'] T '+@PKs
        ,       @STPSQL = @STPSQL + @lCR + '		WHERE   [T].[isDeleted] = 1'
        ,       @STPSQL = @STPSQL + @lCR + '		AND		[T].[Hash] = [V].[Hash]'
        ,       @STPSQL = @STPSQL + @lCR + '		AND		[T].[EndDate] != ''29991231''' 
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '        COMMIT'
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '        --  Audit Data Processing'
        ,       @STPSQL = @STPSQL + @lCR + '       EXECUTE [audit].[spInsertDataLogStorage] '
        ,       @STPSQL = @STPSQL + @lCR + '          @process_run_id = @ProcessRunID'
        ,       @STPSQL = @STPSQL + @lCR + '         ,@pipeline_run_id = @PipelineRunID'
        ,       @STPSQL = @STPSQL + @lCR + '         ,@schema = @Schema'
		,       @STPSQL = @STPSQL + @lCR + '         ,@entity_name = @EntityName'
        ,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_insert = @InputInsertedRows'
        ,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_update = @InputUpdatedRows'
        ,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_delete = @InputDeletedRows'    
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + 'END TRY  '
        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN CATCH  '
        ,       @STPSQL = @STPSQL + @lCR + '        SELECT  @ErrorCode = ERROR_NUMBER()'
        ,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_SEVERITY() AS ErrorSeverity  '
        ,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_STATE() AS ErrorState  '
        ,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_PROCEDURE() AS ErrorProcedure  '
        ,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_LINE() AS ErrorLine  '
        ,       @STPSQL = @STPSQL + @lCR + '        ,       @ErrorDescription = ERROR_MESSAGE();  '
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '        IF @@TRANCOUNT > 0  '
        ,       @STPSQL = @STPSQL + @lCR + '        BEGIN'
        ,       @STPSQL = @STPSQL + @lCR + '                ROLLBACK TRANSACTION; '
        ,       @STPSQL = @STPSQL + @lCR + '        END'
        ,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + '        --  Audit Fout'
        ,       @STPSQL = @STPSQL + @lCR + '		EXECUTE [audit].[spErrorLog]'
        ,       @STPSQL = @STPSQL + @lCR + '		   @ProcessID    = @ProcessRunID'
        ,       @STPSQL = @STPSQL + @lCR + '		  ,@Schema		 = @Schema'
        ,       @STPSQL = @STPSQL + @lCR + '		  ,@EntityName   = @EntityName'
        ,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorCode    = @ErrorCode'
        ,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorDescription = @ErrorDescription '
		,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorType = '+ ''''+ ''''+ ''
		,       @STPSQL = @STPSQL + @lCR + '		   ;'
		,       @STPSQL = @STPSQL + @lCR + '-- Return Error'
		,       @STPSQL = @STPSQL + @lCR + 'THROW'
		,       @STPSQL = @STPSQL + @lCR + ''
        ,       @STPSQL = @STPSQL + @lCR + 'END CATCH  '
        ,       @STPSQL = @STPSQL + @lCR + ''
		,		@STPSQL = @STPSQL + @lCR + '		SELECT'
		,		@STPSQL = @STPSQL + @lCR + '		@ProcessRunID		AS	 ProcessRunID'
		,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lSourceSchema+'''' + 'AS [SourceSchema]'
		,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lSourceTable+''''	+ 'AS [SourceTable]'
		,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lStoSchema+'''' + 'AS [SinkSchema]'
		,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lStoTable+''''	+ 'AS [SinkTable]'
		,		@STPSQL = @STPSQL + @lCR + '		,@TaskName		AS	 TaskName'
		,		@STPSQL = @STPSQL + @lCR + '		,@InputInsertedRows	AS	RowsWritten'
		,		@STPSQL = @STPSQL + @lCR + '		,@InputUpdatedRows 	AS	RowsUpdated'
		,		@STPSQL = @STPSQL + @lCR + '		,@InputDeletedRows 	AS	RowsDeleted'
		,		@STPSQL = @STPSQL + @lCR + '		,@ErrorDescription	AS ErrorDescription'
		,		@STPSQL = @STPSQL + @lCR + '		,@ErrorCode       	AS ErrorCode'
        ,       @STPSQL = @STPSQL + @lCR + 'END'
        ,       @STPSQL = @STPSQL + @lCR + 'GO'
        ,       @STPSQL = @STPSQL + @lCR + ''
	END
------------------------------------------------------------------------------------------------------------------------------------------
/*
Create Stored Procedure that builds SCD type 1 in Storage layer
*/
------------------------------------------------------------------------------------------------------------------------------------------
	BEGIN 
		IF @SCDType = 1 AND @lIncrementStaging = 0
			BEGIN 
			        SELECT  @STPSQL = ''
				,       @STPSQL = @STPSQL + @lCR +'IF OBJECT_ID('+ '''' +@lStoSchema+ '.Load' + @lStoTable + '''' + ') IS NOT NULL' 
				,       @STPSQL = @STPSQL + @lCR +'DROP PROCEDURE'+ '['+@lStoSchema+'].[Load'+@lStoTable+']'
				,       @STPSQL = @STPSQL + @lCR +'GO'
			    ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
			    ,       @STPSQL = @STPSQL + @lCR + '--  Script for ['+@lStoSchema+'].[Load'+@lStoTable+']'
			    ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
			    ,       @STPSQL = @STPSQL + @lCR + '--  '+@ldat+' Generator ' + @lVersion + ' for ' + @pProject + ' project'
			    ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
			    ,       @STPSQL = @STPSQL + @lCR + 'CREATE  PROCEDURE ['+@lStoSchema+'].[Load'+@lStoTable+']'
			    ,       @STPSQL = @STPSQL + @lCR + '        @ProcessRunID      INT'
			    ,       @STPSQL = @STPSQL + @lCR + ',       @PipelineRunID      uniqueidentifier'
			    ,       @STPSQL = @STPSQL + @lCR + ',       @TaskName           VARCHAR(100)'
				,       @STPSQL = @STPSQL + @lCR + ',       @Schema				VARCHAR(100)'
				,       @STPSQL = @STPSQL + @lCR + ',       @EntityName         VARCHAR(100)'
			    ,       @STPSQL = @STPSQL + @lCR + ''
			    ,       @STPSQL = @STPSQL + @lCR + 'AS'
			    ,       @STPSQL = @STPSQL + @lCR + 'BEGIN'
			    ,       @STPSQL = @STPSQL + @lCR + 'DECLARE @InputInsertedRows       INT = 0'
				,       @STPSQL = @STPSQL + @lCR + ',       @InputUpdatedRows         INT = 0'
				,       @STPSQL = @STPSQL + @lCR + ',       @InputDeletedRows        INT = 0'
			    ,       @STPSQL = @STPSQL + @lCR + ',       @ErrorCode          INT = 0'
			    ,       @STPSQL = @STPSQL + @lCR + ',       @ErrorDescription   VARCHAR(MAX)'
			    ,       @STPSQL = @STPSQL + @lCR + ',       @Nu                 DATETIME '
			    ,       @STPSQL = @STPSQL + @lCR + ''
			    ,       @STPSQL = @STPSQL + @lCR + '        SELECT @Nu = GETDATE()'
			    ,       @STPSQL = @STPSQL + @lCR + ' '
			    ,       @STPSQL = @STPSQL + @lCR + ''
			    ,       @STPSQL = @STPSQL + @lCR + ''
			    ,       @STPSQL = @STPSQL + @lCR + 'BEGIN TRY  '
			    ,       @STPSQL = @STPSQL + @lCR + ''
				,       @STPSQL = @STPSQL + @lCR + ''
			    ,       @STPSQL = @STPSQL + @lCR + '        --  Stored Procedure'
			    ,       @STPSQL = @STPSQL + @lCR + '		BEGIN TRANSACTION'
				,       @STPSQL = @STPSQL + @lCR +	 @CommentBreak
				,       @STPSQL = @STPSQL + @lCR +	 '--  Script for Switch table ['+@lStoSchema+'].[sw_' +@lStoTable+ ']'
				,       @STPSQL = @STPSQL + @lCR +	 @CommentBreak
				,       @STPSQL = @STPSQL + @lCR +	 'CREATE  TABLE ['+@lStoSchema+'].[sw_'+@lStoTable+']('
				,       @STPSQL = @STPSQL + @lCR +   '[SCD'+@lStoTable+'Key] INT NOT NULL IDENTITY (1,1),'
				,       @STPSQL = @STPSQL + @lCR +	 @Cols
				,       @STPSQL = @STPSQL + @lCR + ',       [Hash] VARBINARY(8000) NOT NULL'
				,       @STPSQL = @STPSQL + @lCR + ',       [Current] BIT NOT NULL'
				,       @STPSQL = @STPSQL + @lCR + ',       [isDeleted] BIT NOT NULL'
				,       @STPSQL = @STPSQL + @lCR + ',       [StartDate] DATETIME NOT NULL'
				,       @STPSQL = @STPSQL + @lCR + ',       [EndDate] DATETIME NOT NULL DEFAULT ''99991231'''
				,       @STPSQL = @STPSQL + @lCR + ',       [ProcessRunID] INT NOT NULL'
				,       @STPSQL = @STPSQL + @lCR + ')'
				,       @STPSQL = @STPSQL + @lCR +	 '' 
			    ,       @STPSQL = @STPSQL + @lCR + ''
		        ,       @STPSQL = @STPSQL + @lCR + '        --  Insert New records or New versions of records'
			    ,       @STPSQL = @STPSQL + @lCR + '        INSERT  INTO ['+@lStoSchema+'].[sw_'+@lStoTable+']'
			    ,       @STPSQL = @STPSQL + @lCR + '('
			    ,       @STPSQL = @STPSQL + @lCR + REPLACE(Replace(@STPCols,'Select',''),'[V].','')
		        ,       @STPSQL = @STPSQL + @lCR + '		,       [Hash]'
		        ,       @STPSQL = @STPSQL + @lCR + '		,       [Current]'
		        ,       @STPSQL = @STPSQL + @lCR + '		,       [isDeleted]'
				,       @STPSQL = @STPSQL + @lCR + '		,       [StartDate]'
				,       @STPSQL = @STPSQL + @lCR + '		,       [EndDate]'
				,       @STPSQL = @STPSQL + @lCR + '		,       [ProcessRunID]'
			    ,       @STPSQL = @STPSQL + @lCR + ')'
			    ,       @STPSQL = @STPSQL + @lCR + @STPColsT1
			    ,       @STPSQL = @STPSQL + @lCR + '		' + @Hash
			    ,       @STPSQL = @STPSQL + @lCR +'        ,       1' 
			    ,       @STPSQL = @STPSQL + @lCR +'        ,       0' 
			    ,       @STPSQL = @STPSQL + @lCR +'        ,       @Nu' 
			    ,       @STPSQL = @STPSQL + @lCR +'        ,       ''29991231'''
			    ,       @STPSQL = @STPSQL + @lCR + '        ,       @ProcessRunID'
			    ,       @STPSQL = @STPSQL + @lCR + '        FROM    ['+@lSourceSchema+'].['+@lSourcetable+'] V'
			    ,       @STPSQL = @STPSQL + @lCR + '        SELECT @InputInsertedRows = @@ROWCOUNT'
			    ,       @STPSQL = @STPSQL + @lCR + '		'
			    ,       @STPSQL = @STPSQL + @lCR + '        TRUNCATE TABLE ['+@lStoSchema+'].['+@lStoTable+']'
			    ,       @STPSQL = @STPSQL + @lCR + '		ALTER TABLE ['+@lStoSchema+'].[sw_'+@lStoTable+'] SWITCH TO ['+@lStoSchema+'].['+@lStoTable+']'
			    ,       @STPSQL = @STPSQL + @lCR + '		DROP TABLE  ['+@lStoSchema+'].[sw_'+@lStoTable+']'
			    ,       @STPSQL = @STPSQL + @lCR + '		'
			    ,       @STPSQL = @STPSQL + @lCR + '        COMMIT'
				,       @STPSQL = @STPSQL + @lCR + ''
				,       @STPSQL = @STPSQL + @lCR + '        --  Audit Data Processing'
				,       @STPSQL = @STPSQL + @lCR + '       EXECUTE [audit].[spInsertDataLogStorage] '
				,       @STPSQL = @STPSQL + @lCR + '          @process_run_id = @ProcessRunID'
				,       @STPSQL = @STPSQL + @lCR + '         ,@pipeline_run_id = @PipelineRunID'
		        ,       @STPSQL = @STPSQL + @lCR + '         ,@schema = @Schema'
				,       @STPSQL = @STPSQL + @lCR + '         ,@entity_name = @EntityName'
				,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_insert = @InputInsertedRows'
				,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_update = @InputUpdatedRows'
				,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_delete = @InputDeletedRows'    
				,       @STPSQL = @STPSQL + @lCR + ''
				,       @STPSQL = @STPSQL + @lCR + 'END TRY  '
				,       @STPSQL = @STPSQL + @lCR + 'BEGIN CATCH  '
				,       @STPSQL = @STPSQL + @lCR + '        SELECT  @ErrorCode = ERROR_NUMBER()'
				,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_SEVERITY() AS ErrorSeverity  '
				,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_STATE() AS ErrorState  '
				,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_PROCEDURE() AS ErrorProcedure  '
				,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_LINE() AS ErrorLine  '
				,       @STPSQL = @STPSQL + @lCR + '        ,       @ErrorDescription = ERROR_MESSAGE();  '
				,       @STPSQL = @STPSQL + @lCR + ''
				,       @STPSQL = @STPSQL + @lCR + '        IF @@TRANCOUNT > 0  '
				,       @STPSQL = @STPSQL + @lCR + '        BEGIN'
				,       @STPSQL = @STPSQL + @lCR + '                ROLLBACK TRANSACTION; '
				,       @STPSQL = @STPSQL + @lCR + '        END'
				,       @STPSQL = @STPSQL + @lCR + ''
				,       @STPSQL = @STPSQL + @lCR + '        --  Audit Fout'
				,       @STPSQL = @STPSQL + @lCR + '		EXECUTE [audit].[spErrorLog]'
				,       @STPSQL = @STPSQL + @lCR + '		   @ProcessID    = @ProcessRunID'
		        ,       @STPSQL = @STPSQL + @lCR + '		  ,@Schema		 = @Schema'
				,       @STPSQL = @STPSQL + @lCR + '		  ,@EntityName   = @EntityName'
				,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorCode    = @ErrorCode'
				,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorDescription = @ErrorDescription '
				,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorType = '+ ''''+ ''''+ ''
				,       @STPSQL = @STPSQL + @lCR + '		   ;'
				,       @STPSQL = @STPSQL + @lCR + '-- Return Error'
				,       @STPSQL = @STPSQL + @lCR + 'THROW'
				,       @STPSQL = @STPSQL + @lCR + ''
				,       @STPSQL = @STPSQL + @lCR + 'END CATCH  '
				,       @STPSQL = @STPSQL + @lCR + ''
				,		@STPSQL = @STPSQL + @lCR + '		SELECT'
				,		@STPSQL = @STPSQL + @lCR + '		@ProcessRunID		AS	 ProcessRunID'
				,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lSourceSchema+'''' + 'AS [SourceSchema]'
				,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lSourceTable+''''	+ 'AS [SourceTable]'
				,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lStoSchema+'''' + 'AS [SinkSchema]'
				,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lStoTable+''''	+ 'AS [SinkTable]'
				,		@STPSQL = @STPSQL + @lCR + '		,@TaskName		AS	 TaskName'
				,		@STPSQL = @STPSQL + @lCR + '		,@InputInsertedRows	AS	RowsWritten'
				,		@STPSQL = @STPSQL + @lCR + '		,@InputUpdatedRows 	AS	RowsUpdated'
				,		@STPSQL = @STPSQL + @lCR + '		,@InputDeletedRows 	AS	RowsDeleted'
				,		@STPSQL = @STPSQL + @lCR + '		,@ErrorDescription	AS ErrorDescription'
				,		@STPSQL = @STPSQL + @lCR + '		,@ErrorCode       	AS ErrorCode'
				,       @STPSQL = @STPSQL + @lCR + 'END'
			    ,       @STPSQL = @STPSQL + @lCR + ''
			END

------------------------------------------------------------------------------------------------------------------------------------------
/*
Create Stored Procedure that builds SCD type 1 in Storage layer AND Staging is Incremental
*/
------------------------------------------------------------------------------------------------------------------------------------------
		BEGIN 
			IF @SCDType = 1 AND @lIncrementStaging = 1
				BEGIN 
			SELECT  @STPSQL = ''
			,       @STPSQL = @STPSQL + @lCR +'IF OBJECT_ID('+ '''' +@lStoSchema+ '.Load' + @lStoTable + '''' + ') IS NOT NULL' 
			,       @STPSQL = @STPSQL + @lCR +'DROP PROCEDURE'+ '['+@lStoSchema+'].[Load'+@lStoTable+']'
			,       @STPSQL = @STPSQL + @lCR +'GO'
	        ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
	        ,       @STPSQL = @STPSQL + @lCR + '--  Script for ['+@lStoSchema+'].[Load'+@lStoTable+']'
	        ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
	        ,       @STPSQL = @STPSQL + @lCR + '--  '+@ldat+' Generator ' + @lVersion + ' for ' + @pProject + ' project'
	        ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
	        ,       @STPSQL = @STPSQL + @lCR + 'CREATE  PROCEDURE ['+@lStoSchema+'].[Load'+@lStoTable+']'
	        ,       @STPSQL = @STPSQL + @lCR + '        @ProcessRunID      INT'
	        ,       @STPSQL = @STPSQL + @lCR + ',       @PipelineRunID      uniqueidentifier'
	        ,       @STPSQL = @STPSQL + @lCR + ',       @TaskName           VARCHAR(100)'
	        ,       @STPSQL = @STPSQL + @lCR + ',       @Schema				VARCHAR(100)'
	        ,       @STPSQL = @STPSQL + @lCR + ',       @EntityName         VARCHAR(100)'
	        ,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + 'AS'
	        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN'
	        ,       @STPSQL = @STPSQL + @lCR + 'DECLARE @InputInsertedRows       INT = 0'
	        ,       @STPSQL = @STPSQL + @lCR + ',       @InputUpdatedRows         INT = 0'
	        ,       @STPSQL = @STPSQL + @lCR + ',       @InputDeletedRows        INT = 0'
	        ,       @STPSQL = @STPSQL + @lCR + ',       @ErrorCode          INT = 0'
	        ,       @STPSQL = @STPSQL + @lCR + ',       @ErrorDescription   VARCHAR(MAX)'
	        ,       @STPSQL = @STPSQL + @lCR + ',       @Nu                 DATETIME '
	        ,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + 'IF EXISTS (SELECT 1 FROM ['+@lStoSchema+'].['+@lStoTable+'] WHERE [SCD'+@lStoTable+'Key] > 0)'
	        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN'
	        ,       @STPSQL = @STPSQL + @lCR + '        SELECT @Nu = GETDATE()'
	        ,       @STPSQL = @STPSQL + @lCR + 'END'
	        ,       @STPSQL = @STPSQL + @lCR + 'ELSE'
	        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN'
	        ,       @STPSQL = @STPSQL + @lCR + '        SELECT @Nu = ''19000101'''
	        ,       @STPSQL = @STPSQL + @lCR + 'END '
	        ,       @STPSQL = @STPSQL + @lCR + ' '
	        ,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN TRY  '
	        ,       @STPSQL = @STPSQL + @lCR + '        BEGIN TRANSACTION'
	        ,       @STPSQL = @STPSQL + @lCR + @TSQL2
			,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + @INSQL
			,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + '        --  Stored Procedure'
	        ,       @STPSQL = @STPSQL + @lCR + '        --  Update mutated records, Set Enddate and Current = 0'
	        ,       @STPSQL = @STPSQL + @lCR + '        UPDATE  ['+@lStoSchema+'].['+@lStoTable+']'
	        ,       @STPSQL = @STPSQL + @lCR + '        SET     [EndDate] = @Nu'
	        ,       @STPSQL = @STPSQL + @lCR + '        ,       [ProcessRunID] = @ProcessRunID'
	        ,       @STPSQL = @STPSQL + @lCR + '        ,       [Current] = 0'
	        ,       @STPSQL = @STPSQL + @lCR + '        FROM    [#TEMP'+@lStoTable+'] V'
	        ,       @STPSQL = @STPSQL + @lCR + '        LEFT    JOIN    ['+@lStoSchema+'].['+@lStoTable+'] T ' + @PKs
	        ,       @STPSQL = @STPSQL + @lCR + replicate (' ', @lenPK)
	        ,       @STPSQL = @STPSQL + @lCR + '        WHERE   [V].[Hash] != [T].[Hash]'
	        ,       @STPSQL = @STPSQL + @lCR + '        AND     [T].[EndDate] = ''29991231'''
	        ,       @STPSQL = @STPSQL + @lCR + '        SELECT  @InputUpdatedRows = @@ROWCOUNT'
	        ,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + '        --  Insert New records or New versions of records'
	        ,       @STPSQL = @STPSQL + @lCR + '        INSERT  INTO ['+@lStoSchema+'].['+@lStoTable+']'
			,       @STPSQL = @STPSQL + @lCR + '('
			,       @STPSQL = @STPSQL + @lCR + REPLACE(Replace(@STPCols,'Select',''),'[V].','')
			,       @STPSQL = @STPSQL + @lCR + '		,       [Hash]'
			,       @STPSQL = @STPSQL + @lCR + '		,       [Current]'
			,       @STPSQL = @STPSQL + @lCR + '		,       [isDeleted]'
			,       @STPSQL = @STPSQL + @lCR + '		,       [StartDate]'
			,       @STPSQL = @STPSQL + @lCR + '		,       [EndDate]'
			,       @STPSQL = @STPSQL + @lCR + '		,       [ProcessRunID]'
			,       @STPSQL = @STPSQL + @lCR + ')'
	        ,       @STPSQL = @STPSQL + @lCR + @STPCols
	        ,       @STPSQL = @STPSQL + @lCR +'        ,       [V].[Hash]'
	        ,       @STPSQL = @STPSQL + @lCR +'        ,       1' 
	        ,       @STPSQL = @STPSQL + @lCR +'        ,       0' 
	        ,       @STPSQL = @STPSQL + @lCR +'        ,       @Nu' 
	        ,       @STPSQL = @STPSQL + @lCR +'        ,       ''29991231'''
	        ,       @STPSQL = @STPSQL + @lCR + '        ,       @ProcessRunID'
	        ,       @STPSQL = @STPSQL + @lCR + '        FROM    [#TEMP'+@lStoTable+'] V'
	        ,       @STPSQL = @STPSQL + @lCR + '        LEFT    JOIN    ['+@lStoSchema+'].['+@lStoTable+'] T '+@PKs
	        ,       @STPSQL = @STPSQL + @lCR + replicate (' ', @lenPK)
	        ,       @STPSQL = @STPSQL + @lCR + '        WHERE   (([T].[SCD'+@lStoTable+'Key] IS NULL) '
	        ,       @STPSQL = @STPSQL + @lCR + '                OR      ([V].[Hash] != [T].[Hash]))'
	        ,       @STPSQL = @STPSQL + @lCR + '        AND     ISNULL([T].ProcessRunID, @ProcessRunID) = @ProcessRunID'
	        ,       @STPSQL = @STPSQL + @lCR + '        SELECT @InputInsertedRows = @@ROWCOUNT'
	        ,       @STPSQL = @STPSQL + @lCR + '        '
	        ,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + '  		-- Set Removed Records back to Current if record resurfaces'
	        ,       @STPSQL = @STPSQL + @lCR + '        UPDATE  ['+@lStoSchema+'].['+@lStoTable+']'
	        ,       @STPSQL = @STPSQL + @lCR + '		SET     [EndDate] = ''29991231'''
	        ,       @STPSQL = @STPSQL + @lCR + '		,       [ProcessRunID] = @ProcessRunID'
	        ,       @STPSQL = @STPSQL + @lCR + '		,       [Current] = 1'
	        ,       @STPSQL = @STPSQL + @lCR + '		,		[isDeleted] = 0'
	        ,       @STPSQL = @STPSQL + @lCR + '        FROM    [#TEMP'+@lStoTable+'] V'
	        ,       @STPSQL = @STPSQL + @lCR + '        RIGHT    JOIN    ['+@lStoSchema+'].['+@lStoTable+'] T '+@PKs
	        ,       @STPSQL = @STPSQL + @lCR + '		WHERE   [T].[isDeleted] = 1'
	        ,       @STPSQL = @STPSQL + @lCR + '		AND		[T].[Hash] = [V].[Hash]'
	        ,       @STPSQL = @STPSQL + @lCR + '		AND		[T].[EndDate] != ''29991231''' 
	        ,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + '        COMMIT'
	        ,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + '        --  Audit Data Processing'
	        ,       @STPSQL = @STPSQL + @lCR + '       EXECUTE [audit].[spInsertDataLogStorage] '
	        ,       @STPSQL = @STPSQL + @lCR + '          @process_run_id = @ProcessRunID'
	        ,       @STPSQL = @STPSQL + @lCR + '         ,@pipeline_run_id = @PipelineRunID'
	        ,       @STPSQL = @STPSQL + @lCR + '         ,@schema = @Schema'
			,       @STPSQL = @STPSQL + @lCR + '         ,@entity_name = @EntityName'
	        ,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_insert = @InputInsertedRows'
	        ,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_update = @InputUpdatedRows'
	        ,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_delete = @InputDeletedRows'    
	        ,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + 'END TRY  '
	        ,       @STPSQL = @STPSQL + @lCR + 'BEGIN CATCH  '
	        ,       @STPSQL = @STPSQL + @lCR + '        SELECT  @ErrorCode = ERROR_NUMBER()'
	        ,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_SEVERITY() AS ErrorSeverity  '
	        ,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_STATE() AS ErrorState  '
	        ,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_PROCEDURE() AS ErrorProcedure  '
	        ,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_LINE() AS ErrorLine  '
	        ,       @STPSQL = @STPSQL + @lCR + '        ,       @ErrorDescription = ERROR_MESSAGE();  '
	        ,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + '        IF @@TRANCOUNT > 0  '
	        ,       @STPSQL = @STPSQL + @lCR + '        BEGIN'
	        ,       @STPSQL = @STPSQL + @lCR + '                ROLLBACK TRANSACTION; '
	        ,       @STPSQL = @STPSQL + @lCR + '        END'
	        ,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + '        --  Audit Error'
	        ,       @STPSQL = @STPSQL + @lCR + '		EXECUTE [audit].[spErrorLog]'
	        ,       @STPSQL = @STPSQL + @lCR + '		   @ProcessID    = @ProcessRunID'
	        ,       @STPSQL = @STPSQL + @lCR + '		  ,@Schema		 = @Schema'
	        ,       @STPSQL = @STPSQL + @lCR + '		  ,@EntityName   = @EntityName'
	        ,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorCode    = @ErrorCode'
	        ,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorDescription = @ErrorDescription '
			,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorType = '+ ''''+ ''''+ ''
			,       @STPSQL = @STPSQL + @lCR + '		   ;'
			,       @STPSQL = @STPSQL + @lCR + '-- Return Error'
			,       @STPSQL = @STPSQL + @lCR + 'THROW'
			,       @STPSQL = @STPSQL + @lCR + ''
	        ,       @STPSQL = @STPSQL + @lCR + 'END CATCH  '
	        ,       @STPSQL = @STPSQL + @lCR + ''
			,		@STPSQL = @STPSQL + @lCR + '		SELECT'
			,		@STPSQL = @STPSQL + @lCR + '		@ProcessRunID		AS	 ProcessRunID'
			,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lSourceSchema+'''' + 'AS [SourceSchema]'
			,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lSourceTable+''''	+ 'AS [SourceTable]'
			,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lStoSchema+'''' + 'AS [SinkSchema]'
			,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lStoTable+''''	+ 'AS [SinkTable]'
			,		@STPSQL = @STPSQL + @lCR + '		,@TaskName		AS	 TaskName'
			,		@STPSQL = @STPSQL + @lCR + '		,@InputInsertedRows	AS	RowsWritten'
			,		@STPSQL = @STPSQL + @lCR + '		,@InputUpdatedRows 	AS	RowsUpdated'
			,		@STPSQL = @STPSQL + @lCR + '		,@InputDeletedRows 	AS	RowsDeleted'
			,		@STPSQL = @STPSQL + @lCR + '		,@ErrorDescription	AS ErrorDescription'
			,		@STPSQL = @STPSQL + @lCR + '		,@ErrorCode       	AS ErrorCode'
	        ,       @STPSQL = @STPSQL + @lCR + 'END'
	        ,       @STPSQL = @STPSQL + @lCR + 'GO'
	        ,       @STPSQL = @STPSQL + @lCR + ''
		END
	END
------------------------------------------------------------------------------------------------------------------------------------------
/*
Create Stored Procedure that builds SCD type 0 in Storage layer (Never Changing after first insert)
*/
------------------------------------------------------------------------------------------------------------------------------------------
						IF @SCDType = 0
					BEGIN
					        SELECT  @STPSQL = ''
						,       @STPSQL = @STPSQL + @lCR +'IF OBJECT_ID('+ '''' +@lStoSchema+ '.Load' + @lStoTable + '''' + ') IS NOT NULL' 
						,       @STPSQL = @STPSQL + @lCR +'DROP PROCEDURE'+ '['+@lStoSchema+'].[Load'+@lStoTable+']'
						,       @STPSQL = @STPSQL + @lCR +'GO'
					    ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
					    ,       @STPSQL = @STPSQL + @lCR + '--  Script for ['+@lStoSchema+'].[Load'+@lStoTable+']'
					    ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
					    ,       @STPSQL = @STPSQL + @lCR + '--  '+@ldat+' Generator ' + @lVersion + ' for ' + @pProject + ' project'
					    ,       @STPSQL = @STPSQL + @lCR + @CommentBreak
					    ,       @STPSQL = @STPSQL + @lCR + 'CREATE  PROCEDURE ['+@lStoSchema+'].[Load'+@lStoTable+']'
					    ,       @STPSQL = @STPSQL + @lCR + '        @ProcessRunID      INT'
					    ,       @STPSQL = @STPSQL + @lCR + ',       @PipelineRunID      uniqueidentifier'
					    ,       @STPSQL = @STPSQL + @lCR + ',       @TaskName           VARCHAR(100)'
						,       @STPSQL = @STPSQL + @lCR + ',       @Schema				VARCHAR(100)'
						,       @STPSQL = @STPSQL + @lCR + ',       @EntityName         VARCHAR(100)'
					    ,       @STPSQL = @STPSQL + @lCR + ''
					    ,       @STPSQL = @STPSQL + @lCR + 'AS'
					    ,       @STPSQL = @STPSQL + @lCR + 'BEGIN'
					    ,       @STPSQL = @STPSQL + @lCR + 'DECLARE @InputInsertedRows       INT = 0'
						,       @STPSQL = @STPSQL + @lCR + ',       @InputUpdatedRows         INT = 0'
						,       @STPSQL = @STPSQL + @lCR + ',       @InputDeletedRows        INT = 0'
					    ,       @STPSQL = @STPSQL + @lCR + ',       @ErrorCode          INT = 0'
					    ,       @STPSQL = @STPSQL + @lCR + ',       @ErrorDescription   VARCHAR(MAX)'
					    ,       @STPSQL = @STPSQL + @lCR + ',       @Nu                 DATETIME '
					    ,       @STPSQL = @STPSQL + @lCR + ''
					    ,       @STPSQL = @STPSQL + @lCR + '        SELECT @Nu = GETDATE()'
					    ,       @STPSQL = @STPSQL + @lCR + ' '
					    ,       @STPSQL = @STPSQL + @lCR + ''
					    ,       @STPSQL = @STPSQL + @lCR + ''
					    ,       @STPSQL = @STPSQL + @lCR + 'BEGIN TRY  '
					    ,       @STPSQL = @STPSQL + @lCR + ''
						,       @STPSQL = @STPSQL + @lCR + ''
					    ,       @STPSQL = @STPSQL + @lCR + ' IF NOT EXISTS (SELECT Top 1 * from ['+@lStoSchema+'].['+@lStoTable+'])'
						,       @STPSQL = @STPSQL + @lCR + ''
					    ,       @STPSQL = @STPSQL + @lCR + '        --  Stored Procedure'
					    ,       @STPSQL = @STPSQL + @lCR + '		BEGIN TRANSACTION'
					    ,       @STPSQL = @STPSQL + @lCR + '		TRUNCATE TABLE ['+@lStoSchema+'].['+@lStoTable+']'
					    ,       @STPSQL = @STPSQL + @lCR + ''
					    ,       @STPSQL = @STPSQL + @lCR + '        --  insert voor nieuwe / gemuteerde records'
					    ,       @STPSQL = @STPSQL + @lCR + '        INSERT  INTO ['+@lStoSchema+'].['+@lStoTable+']'
					    ,       @STPSQL = @STPSQL + @lCR + '('
					    ,       @STPSQL = @STPSQL + @lCR + REPLACE(Replace(@STPCols,'Select',''),'[V].','')
					    ,       @STPSQL = @STPSQL + @lCR + '		,       [Hash]'
					    ,       @STPSQL = @STPSQL + @lCR + '		,       [Current]'
					    ,       @STPSQL = @STPSQL + @lCR + '		,       [isDeleted]'
						,       @STPSQL = @STPSQL + @lCR + '		,       [StartDate]'
						,       @STPSQL = @STPSQL + @lCR + '		,       [EndDate]'
						,       @STPSQL = @STPSQL + @lCR + '		,       [ProcessRunID]'
					    ,       @STPSQL = @STPSQL + @lCR + ')'
					    ,       @STPSQL = @STPSQL + @lCR + @STPColsT1
					    ,       @STPSQL = @STPSQL + @lCR + '		' + @Hash
					    ,       @STPSQL = @STPSQL + @lCR +'        ,       1' 
					    ,       @STPSQL = @STPSQL + @lCR +'        ,       0' 
					    ,       @STPSQL = @STPSQL + @lCR +'        ,       @Nu' 
					    ,       @STPSQL = @STPSQL + @lCR +'        ,       ''29991231'''
					    ,       @STPSQL = @STPSQL + @lCR + '        ,       @ProcessRunID'
					    ,       @STPSQL = @STPSQL + @lCR + '        FROM    ['+@lSourceSchema+'].['+@lSourcetable+'] V'
					    ,       @STPSQL = @STPSQL + @lCR + '        SELECT @InputInsertedRows = @@ROWCOUNT'
					    ,       @STPSQL = @STPSQL + @lCR + '        '
					    ,       @STPSQL = @STPSQL + @lCR + '        COMMIT'
						,       @STPSQL = @STPSQL + @lCR + ''
						,       @STPSQL = @STPSQL + @lCR + '        --  Audit Data Processing'
						,       @STPSQL = @STPSQL + @lCR + '       EXECUTE [audit].[spInsertDataLogStorage] '
						,       @STPSQL = @STPSQL + @lCR + '          @process_run_id = @ProcessRunID'
						,       @STPSQL = @STPSQL + @lCR + '         ,@pipeline_run_id = @PipelineRunID'
						,       @STPSQL = @STPSQL + @lCR + '         ,@schema = @Schema'
						,       @STPSQL = @STPSQL + @lCR + '         ,@entity_name = @EntityName'
						,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_insert = @InputInsertedRows'
						,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_update = @InputUpdatedRows'
						,       @STPSQL = @STPSQL + @lCR + '         ,@rows_affected_delete = @InputDeletedRows'    
						,       @STPSQL = @STPSQL + @lCR + ''
						,       @STPSQL = @STPSQL + @lCR + 'END TRY  '
						,       @STPSQL = @STPSQL + @lCR + 'BEGIN CATCH  '
						,       @STPSQL = @STPSQL + @lCR + '        SELECT  @ErrorCode = ERROR_NUMBER()'
						,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_SEVERITY() AS ErrorSeverity  '
						,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_STATE() AS ErrorState  '
						,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_PROCEDURE() AS ErrorProcedure  '
						,       @STPSQL = @STPSQL + @lCR + '        --,       ERROR_LINE() AS ErrorLine  '
						,       @STPSQL = @STPSQL + @lCR + '        ,       @ErrorDescription = ERROR_MESSAGE();  '
						,       @STPSQL = @STPSQL + @lCR + ''
						,       @STPSQL = @STPSQL + @lCR + '        IF @@TRANCOUNT > 0  '
						,       @STPSQL = @STPSQL + @lCR + '        BEGIN'
						,       @STPSQL = @STPSQL + @lCR + '                ROLLBACK TRANSACTION; '
						,       @STPSQL = @STPSQL + @lCR + '        END'
						,       @STPSQL = @STPSQL + @lCR + ''
						,       @STPSQL = @STPSQL + @lCR + '        --  Audit Error'
						,       @STPSQL = @STPSQL + @lCR + '		EXECUTE [audit].[spErrorLog]'
						,       @STPSQL = @STPSQL + @lCR + '		   @ProcessID    = @ProcessRunID'
					    ,       @STPSQL = @STPSQL + @lCR + '		  ,@Schema		 = @Schema'
						,       @STPSQL = @STPSQL + @lCR + '		  ,@EntityName   = @EntityName'
						,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorCode    = @ErrorCode'
						,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorDescription = @ErrorDescription '
						,       @STPSQL = @STPSQL + @lCR + '		  ,@ErrorType = '+ ''''+ ''''+ ''
						,       @STPSQL = @STPSQL + @lCR + '		   ;'
						,       @STPSQL = @STPSQL + @lCR + '-- Return Error'
						,       @STPSQL = @STPSQL + @lCR + 'THROW'
						,       @STPSQL = @STPSQL + @lCR + ''
						,       @STPSQL = @STPSQL + @lCR + 'END CATCH  '
						,       @STPSQL = @STPSQL + @lCR + ''
						,		@STPSQL = @STPSQL + @lCR + '		SELECT'
						,		@STPSQL = @STPSQL + @lCR + '		@ProcessRunID		AS	 ProcessRunID'
						,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lSourceSchema+'''' + 'AS [SourceSchema]'
						,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lSourceTable+''''	+ 'AS [SourceTable]'
						,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lStoSchema+'''' + 'AS [SinkSchema]'
						,		@STPSQL = @STPSQL + @lCR + '		,' + '''' + @lStoTable+''''	+ 'AS [SinkTable]'
						,		@STPSQL = @STPSQL + @lCR + '		,@TaskName		AS	 TaskName'
						,		@STPSQL = @STPSQL + @lCR + '		,@InputInsertedRows	AS	RowsWritten'
						,		@STPSQL = @STPSQL + @lCR + '		,@InputUpdatedRows 	AS	RowsUpdated'
						,		@STPSQL = @STPSQL + @lCR + '		,@InputDeletedRows 	AS	RowsDeleted'
						,		@STPSQL = @STPSQL + @lCR + '		,@ErrorDescription	AS ErrorDescription'
						,		@STPSQL = @STPSQL + @lCR + '		,@ErrorCode       	AS ErrorCode'
						,       @STPSQL = @STPSQL + @lCR + 'END'
					    ,       @STPSQL = @STPSQL + @lCR + ''
					END	
	END
------------------------------------------------------------------------------------------------------------------------------------------
/*
Create Storage view
*/
------------------------------------------------------------------------------------------------------------------------------------------
        SELECT  @PBISQL = ''
        ,       @PBISQL = @PBISQL + @lCR + @CommentBreak
        ,       @PBISQL = @PBISQL + @lCR + '--  Script for ['+@lPBISchema+'].[' +@lStoTable+ ']'
        ,       @PBISQL = @PBISQL + @lCR + @CommentBreak
        ,       @PBISQL = @PBISQL + @lCR + '--  '+@ldat+' Generator ' + @lVersion + ' for ' + @pProject + ' project'
        ,       @PBISQL = @PBISQL + @lCR + @CommentBreak
        ,       @PBISQL = @PBISQL + @lCR + 'CREATE VIEW ['+@lPBISchema+'].[' + @lStoTable + ']'
        ,       @PBISQL = @PBISQL + @lCR + 'AS'
        ,       @PBISQL = @PBISQL + @lCR + 'SELECT  [SCD'+ @lStoTable + 'Key]'
        ,       @PBISQL = @PBISQL + @lCR + @PBICols
        ,       @PBISQL = @PBISQL + @lCR + ',       [Current]'
        ,       @PBISQL = @PBISQL + @lCR + ',       [StartDatum]'
        ,       @PBISQL = @PBISQL + @lCR + ',       [EndDate]'
        ,       @PBISQL = @PBISQL + @lCR +'FROM    ['+@lStoSchema+'].[' + @lStoTable + ']'
        ,       @PBISQL = @PBISQL + @lCR + 'GO'
        ,       @PBISQL = @PBISQL + @lCR + ''
 ------------------------------------------------------------------------------------------------------------------------------------------
/*
Create Storage view with only SCDCurrent = 1 values
*/
------------------------------------------------------------------------------------------------------------------------------------------       
        SELECT  @PBISQL1 = ''
        ,       @PBISQL1 = @PBISQL1 + @lCR + @CommentBreak
        ,       @PBISQL1 = @PBISQL1 + @lCR + '--  Script for ['+@lPBISchemaCurrent+'].[' +@lStoTable+ ']'
        ,       @PBISQL1 = @PBISQL1 + @lCR + @CommentBreak
        ,       @PBISQL1 = @PBISQL1 + @lCR + '--  '+@ldat+' Generator ' + @lVersion + ' for ' + @pProject + ' project'
        ,       @PBISQL1 = @PBISQL1 + @lCR + @CommentBreak
        ,       @PBISQL1 = @PBISQL1 + @lCR + 'CREATE VIEW ['+@lPBISchemaCurrent+'].[' + @lStoTable + ']'
        ,       @PBISQL1 = @PBISQL1 + @lCR + 'AS'
        ,       @PBISQL1 = @PBISQL1 + @lCR + 'SELECT  [SCD'+ @lStoTable + 'Key]'
        ,       @PBISQL1 = @PBISQL1 + @lCR +  @PBICols
        ,       @PBISQL1 = @PBISQL1 + @lCR +  ',       [Current]'
        ,       @PBISQL1 = @PBISQL1 + @lCR +  ',       [StartDatum]'
        ,       @PBISQL1 = @PBISQL1 + @lCR +  ',       [EndDate]'
        ,       @PBISQL1 = @PBISQL1 + @lCR + 'FROM    ['+@lStoSchema+'].[' + @lStoTable + '] Where SCDCurrent = 1'
        ,       @PBISQL1 = @PBISQL1 + @lCR + 'GO'
        ,       @PBISQL1 = @PBISQL1 + @lCR + ''
------------------------------------------------------------------------------------------------------------------------------------------
/*
Select differnent scripts
*/
------------------------------------------------------------------------------------------------------------------------------------------
 SELECT  @pProject AS [Project]
        ,       @lStoTable AS [Object]
        ,       @TSQL		AS [Storage_Tabel]
        ,       @STPSQL		AS [Storage_Procedure]
        ,       @PBISQL		AS [PowerBIView]
		,		@PBISQL1 AS [PowerBIViewCurrent]


------------------------------------------------------------------------------------------------------------------------------------------
/*
Execute create table Script to create dwh table also available for Reuse in mddb views	
*/
------------------------------------------------------------------------------------------------------------------------------------------
 EXEC(@TSQLMDDB)
 PRINT(@TSQLMDDB)
 
END