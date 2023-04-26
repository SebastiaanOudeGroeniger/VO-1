CREATE PROCEDURE [audit].[spEndProcessRun]
    @process_run_id int
AS
BEGIN
    UPDATE [audit].ProcessRun
        SET EndDate = GETDATE()
    WHERE [id] = @process_run_id

END
