CREATE PROCEDURE [elt].[spSystemStorageDays] AS

SELECT st.SystemName, 
st.StorageDays * -1 as StorageDays, 
CONCAT('raw/', st.SystemName, '/') AS FolderPath
FROM [elt].[SystemStorageDays] st
INNER JOIN elt.MetadataSystem sy
	ON st.SystemName = sy.SystemName
	AND sy.Active = 1
--where SystemName = @system_name
