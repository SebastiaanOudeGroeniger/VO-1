CREATE PROCEDURE [elt].[spLookupLevels]

AS
SELECT DISTINCT Level
FROM [elt].[StorageTables]
WHERE 1 = 1
    AND [Active] = 1
ORDER BY Level ASC
