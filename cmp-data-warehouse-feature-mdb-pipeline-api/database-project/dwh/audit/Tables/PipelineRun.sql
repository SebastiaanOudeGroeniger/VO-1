CREATE TABLE [audit].[PipelineRun] (
    [id] UNIQUEIDENTIFIER NOT NULL,
    [Name] VARCHAR (64) NOT NULL,
    [StartDate] DATETIME2 (7) NOT NULL,
    [EndDate] DATETIME2 (7) NULL,
    [ProcessRunId] INT NOT NULL
);
