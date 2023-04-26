CREATE TABLE [elt].[UseCaseEntity](
	[UseCaseCode] [nvarchar](50) NOT NULL,
	[SystemCode] [nvarchar](50) NOT NULL,
	[EntityName] [nvarchar](50) NOT NULL UNIQUE,
	[SchemaName] [nvarchar](50) NOT NULL,
	[Active] [bit] NULL
)