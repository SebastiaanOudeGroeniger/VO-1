CREATE PROCEDURE [audit].[spStartProcessRun]	@pipeline_run_id        UNIQUEIDENTIFIER, 
                                                @pipeline_name          [VARCHAR](64), 
                                                @trigger_type           VARCHAR(32), 
                                                @trigger_name           VARCHAR(256), 
                                                @trigger_id             VARCHAR(50), 
                                                @trigger_time           DATETIME2, 
                                                @trigger_start_time     DATETIME2, 
                                                @data_factory_name      VARCHAR(256)
AS
    BEGIN
        DECLARE @current_process_run_id INT;
        INSERT INTO [audit].ProcessRun
        (TriggerType, 
         TriggerName, 
         TriggerId, 
         TriggerTime, 
         TriggerStartTime, 
         DataFactoryName, 
         StartDate
        )
        VALUES
        (@trigger_type, 
         @trigger_name, 
         @trigger_id, 
         @trigger_time, 
         @trigger_start_time, 
         @data_factory_name, 
         GETDATE()
        );
        SET @current_process_run_id = @@IDENTITY;

        SELECT @current_process_run_id AS [process_run_id];
    END;
