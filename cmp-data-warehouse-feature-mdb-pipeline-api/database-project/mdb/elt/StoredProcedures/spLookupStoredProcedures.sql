CREATE PROCEDURE [elt].[spLookupStoredProcedures]
    @level INT
AS
BEGIN

    SELECT
        [Schema], --*1 Project is the schema of the storage layer. *2 Stored procedures should have 'Load_' as a preposition in the name.
        [EntityName],
        CONCAT(
            '[', [Schema]/*1*/, '].[Load_'/*2*/, [EntityName], ']'
        ) AS [Procedure]
    FROM [elt].[StorageTables]
    WHERE 1 = 1
        --AND [TableType] = 'Dim' 
        AND [Level] = @level
        AND [Active] = 1

END
