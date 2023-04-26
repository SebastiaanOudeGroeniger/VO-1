-- managed identity Synapse Workspace
CREATE USER [sywsvocmpdevweu001] WITH SID = 0x9695758E99EDEE4FA3BD86408F5B0053, TYPE = E;
GO
ALTER ROLE [db_owner] ADD MEMBER [sywsvocmpdevweu001]
GO
