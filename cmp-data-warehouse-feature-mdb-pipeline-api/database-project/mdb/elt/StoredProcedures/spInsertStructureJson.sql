CREATE Procedure [elt].[spInsertStructureJson]
(
@SystemCode	 nvarchar(128)
,@SystemName nvarchar(128)
,@lSchema	 nvarchar(128)
,@lTable	 nvarchar(128)
,@JSON		 nvarchar(max)
)
AS
										BEGIN
								
											INSERT INTO [elt].[MetadataStructure]
														([SystemCode]
														,[SystemName]
														,[SchemaName]
														,[EntityName]
														,[Name]
														,[DataType]
														,[CharacterMaximumLength]
														,[IsNullable]
														,[OrdinalPosition]
														,[NumericPrecision]
														,[NumericScale]
														,[DatetimeCulture]
														,[DatetimeFormat]
														,[IsActive]
														,[IsPrimaryKey]
														,[PrimaryKeyOrdinal]
														,[IsHistory]
														,[LastModifiedDate])
							
											 SELECT		 @SystemCode,
														 @SystemName,
														 @lSchema AS 'Schema',  
														 @lTable AS 'Table',
														 [name],
														 [Type],
														 character_maximum_length = CASE WHEN [type] = 'String' THEN -1 ELSE NULL END,
														 is_nullable = 1,
														 ordinal_position = ROW_NUMBER() OVER (ORDER BY (Select NULL)),
														 numeric_precision = CASE WHEN [type] IN ('decimal') THEN 30 ELSE NULL END,
														 numeric_scale = CASE WHEN  [type] IN ('decimal') THEN 10 ELSE NULL END,
														 datetime_culture = NULL,
														 datetime_format = NULL,
														 isactive = 1,
														 is_primary_key = 0,
														 primary_key_ordinal = NULL,
														 IsHistory = 1,
														 LastModifiedDate = getdate()
								        FROM OPENJSON(@JSON)
										WITH (
								            [name] nvarchar(500) '$.name',
								            [type] nvarchar(500) '$.type'
												) AS Js

							 END