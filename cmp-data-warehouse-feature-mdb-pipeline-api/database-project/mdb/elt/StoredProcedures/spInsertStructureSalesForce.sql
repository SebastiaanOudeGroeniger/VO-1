CREATE Procedure [elt].[spInsertStructureSalesForce]
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
							
											    SELECT	@SystemCode,
												@SystemName,
												@lSchema,  
												@lTable,
								                [name],
												[type],
												character_maximum_length,
								                is_nullable,
								                ordinal_position = ROW_NUMBER() OVER (ORDER BY (Select NULL)),
								                numeric_precision,
								                numeric_scale,
								                datetime_culture = NULL,
								                datetime_format = NULL,
												isactive = 1,
								                is_primary_key = 0,
								                primary_key_ordinal = NULL,
												IsHistory = 1,
												LastModifiedDate = getdate()
								        FROM OPENJSON(@JSON)
										WITH (
											[character_maximum_length]  varchar(500) '$.Length',
								            [name] varchar(500) '$.QualifiedApiName',
								            [type] varchar(500) '$.ServiceDataTypeId',
											[is_nullable] varchar(500) '$.IsNillable',
											[numeric_precision] int  '$.Precision',
											[numeric_scale] int '$.Scale'
												) AS Js

							 END