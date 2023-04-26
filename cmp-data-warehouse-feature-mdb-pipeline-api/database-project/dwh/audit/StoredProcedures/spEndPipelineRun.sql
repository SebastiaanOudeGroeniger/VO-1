CREATE PROCEDURE [audit].[spEndPipelineRun]
    @pipeline_run_id uniqueidentifier
AS
BEGIN
    UPDATE [audit].PipelineRun
        SET EndDate = GETDATE()
    WHERE [id] = @pipeline_run_id
END
