CREATE TABLE [elt].[MetadataTables] (
    [SystemCode] NVARCHAR (30) NOT NULL,
    [SystemName] NVARCHAR (64) NOT NULL,
    [SchemaName] NVARCHAR (50) NOT NULL,
    [EntityName] NVARCHAR (64) NOT NULL,
    [CopyToRaw] BIT NOT NULL,
    [CopyToStg] BIT NOT NULL,
    [SourceQuery] NVARCHAR (MAX) NULL,
    [IsActive] BIT NULL,
    [LastProcessRun] DATETIME NULL,
    [IncrementColumnName] NVARCHAR (64) NULL,
    [IncrementRange] INT NULL,
    [LastIncrement] DATETIME NULL,
    [LastModified] DATETIME NULL
);


GO
CREATE CLUSTERED INDEX [IX_MetadataTables_Entitname]
    ON [elt].[MetadataTables]([EntityName] ASC);
