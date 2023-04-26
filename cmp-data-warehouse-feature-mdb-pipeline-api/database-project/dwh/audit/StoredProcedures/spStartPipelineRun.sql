CREATE PROCEDURE [audit].[spStartPipelineRun]
    @pipeline_run_id uniqueidentifier,
    @pipeline_name [varchar](64),
    @process_run_id [int]

AS
BEGIN

    INSERT INTO [audit].[PipelineRun]
    ([id],
        [Name],
        [StartDate],
        [ProcessRunId])
    VALUES
    (@pipeline_run_id,
        @pipeline_name,
        GETDATE(),
        @process_run_id)

END
