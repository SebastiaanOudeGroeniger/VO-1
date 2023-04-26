CREATE TABLE [audit].[ProcessError] (
    [ProcessErrorID] INT IDENTITY (1, 1) NOT NULL,
    [ProcessRunID] INT NOT NULL,
    [PackageName] VARCHAR (MAX) NULL,
    [Schema] NVARCHAR (100) NULL,
    [EntityName] VARCHAR (MAX) NOT NULL,
    [ErrorType] INT NULL,
    [ErrorCode] INT NULL,
    [ErrorDescription] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_ProcessError] PRIMARY KEY CLUSTERED ([ProcessErrorID] ASC)
);
