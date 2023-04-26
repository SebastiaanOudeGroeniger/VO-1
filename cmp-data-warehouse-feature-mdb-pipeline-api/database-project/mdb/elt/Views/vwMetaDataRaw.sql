CREATE   VIEW [elt].[vwMetaDataRaw]
AS
     SELECT st.[SystemCode],
			st.[SystemName], 
            sy.[SystemType],
			st.[SchemaName],
            st.[EntityName], 
            st.[Name],
			st.[SemanticName],
			st.[DataType],
            st.[CharacterMaximumLength], 
            st.[IsNullable], 
            st.[OrdinalPosition], 
            st.[NumericPrecision], 
            st.[NumericScale], 
            st.[DatetimeCulture], 
            st.[DatetimeFormat], 
			tm.[SourceDataType], 
            tm.InterimDataType, 
            tm.SinkDataType,
			ue.UseCaseCode 
     FROM [elt].[MetadataStructure] st
          INNER JOIN [elt].[MetadataSystem] sy ON sy.[SystemName] = st.[SystemName]
          INNER JOIN [elt].[TypeMap] tm	ON st.[DataType] = tm.[SourceDataType]
		  AND sy.[SystemType] = tm.[SystemType]
		  INNER JOIN [elt].[UseCaseEntity] ue
          INNER JOIN [elt].[UseCase] u ON u.[UseCaseCode] = ue.[UseCaseCode] 
          ON ue.[SystemCode] = st.[SystemCode]
          AND ue.[EntityName] = st.[EntityName]
          AND ue.[SchemaName] = st.[SchemaName]
     WHERE st.IsActive = 1
	 AND ue.Active = 1
     AND u.Active = 1;