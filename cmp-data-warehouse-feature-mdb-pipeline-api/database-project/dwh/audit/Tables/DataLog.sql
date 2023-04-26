CREATE TABLE [audit].[DataLog] (
    [ProcessRunId] INT NULL,
    [PipelineRunId] UNIQUEIDENTIFIER NULL,
    [Type] NVARCHAR (100) NULL,
    [Schema] NVARCHAR (100) NULL,
    [EntityName] NVARCHAR (100) NULL,
    [InsertedRecords] INT NULL,
    [UpdatedRecords] INT NULL,
    [DeletedRecords] INT NULL,
    [TotalRecords] INT NULL,
    [LogDate] DATETIME NULL
);
