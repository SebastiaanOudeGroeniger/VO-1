CREATE TABLE [elt].[StorageTables] (
    [TableID] INT IDENTITY (1, 1) NOT NULL,
    [TableType] VARCHAR (4) NOT NULL,
    [Level] INT NOT NULL,
    [ParallelID] TINYINT NOT NULL,
    [EntityName] NVARCHAR (100) NOT NULL,
    [Schema] VARCHAR (50) NOT NULL,
    [Active] BIT NOT NULL,
    [Comment] NVARCHAR (255) NULL
);
