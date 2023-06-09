﻿/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

/* Truncate before insert */
TRUNCATE TABLE [elt].[TypeMap]

/*Insert metadata records */
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'bigint', N'int64', N'sqlserver', N'bigint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'bit', N'int16', N'sqlserver', N'bit')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'datetime', N'datetime', N'sqlserver', N'datetime')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'decimal', N'decimal', N'sqlserver', N'decimal')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'float', N'double', N'sqlserver', N'float')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'int', N'int32', N'sqlserver', N'int')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'money', N'decimal', N'sqlserver', N'money')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'nvarchar', N'string', N'sqlserver', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'smallint', N'int32', N'sqlserver', N'smallint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'timestamp', N'byte[]', N'sqlserver', N'timestamp')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'tinyint', N'int16', N'sqlserver', N'tinyint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'uniqueidentifier', N'string', N'sqlserver', N'Nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'varbinary', N'byte[]', N'sqlserver', N'varbinary')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'varchar', N'string', N'sqlserver', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'xml', N'string', N'sqlserver', N'xml')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'numeric', N'double', N'mysqlserver', N'decimal')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'double', N'double', N'mysqlserver', N'int')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'enum', N'string', N'mysqlserver', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'text', N'string', N'mysqlserver', N'varchar(max)')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'tinyint', N'int32', N'mysqlserver', N'int')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'char', N'string', N'mysqlserver', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'address', N'string', N'salesforce', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'bit', N'int16', N'mysql', N'bit')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'date', N'date', N'salesforce', N'date')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'float', N'double', N'salesforce', N'decimal')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'id', N'string', N'salesforce', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'integer', N'int32', N'salesforce', N'int')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'string', N'string', N'salesforce', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'int32', N'int32', N'json', N'int')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'byte[]', N'byte[]', N'json', N'varbinary')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'string', N'string', N'json', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'boolean', N'int', N'salesforce', N'bit')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'number(10)', N'int32', N'oracle', N'int')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'char(36)', N'guid', N'oracle', N'Nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'number(19,4)', N'double', N'oracle', N'money')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'number(10,4)', N'double', N'oracle', N'small money')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'datetime2', N'date', N'sqlserver', N'datetime2')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'smalldatetime', N'datetime', N'sqlserver', N'datetime')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'geometry', N'string', N'sqlserver', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'ntext', N'string', N'sqlserver', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'char', N'string', N'sqlserver', N'char')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'date', N'date', N'sqlserver', N'date')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'tinyint', N'byte', N'sql server', N'tinyint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'smallint', N'int16', N'sql server', N'smallint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'int', N'int32', N'sql server', N'int')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'bigint', N'int64', N'sql server', N'bigint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'bit', N'boolean', N'sql server', N'boolean')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'float', N'double', N'sql server', N'double')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'real', N'single', N'sql server', N'float')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'money', N'decimal', N'sql server', N'money')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'smallmoney', N'decimal', N'sql server', N'smallmoney')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'nchar', N'string', N'sql server', N'nchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'nvarchar', N'string', N'sql server', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'char', N'string', N'sql server', N'char')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'varchar', N'string', N'sql server', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'binary', N'byte[]', N'sql server', N'binary')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'varbinary', N'byte[]', N'sql server', N'varbinary')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'date', N'datetime', N'sql server', N'date')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'smalldatetime', N'datetime', N'sql server', N'smalldatetime')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'datetime2', N'datetime', N'sql server', N'datetime2')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'datetime', N'datetime', N'sql server', N'datetime')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'time', N'timespan', N'sql server', N'time')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'decimal', N'decimal', N'sql server', N'decimal')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'number', N'double', N'oracle', N'decimal')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'long', N'string', N'oracle', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'binary_float', N'single', N'oracle', N'real')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'binary_double', N'double', N'oracle', N'float')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'varchar2', N'string', N'oracle', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'nvarchar2', N'string', N'oracle', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'raw', N'byte[]', N'oracle', N'varbinary')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'long raw', N'byte[]', N'oracle', N'varbinary')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'blob', N'byte[]', N'oracle', N'varbinary')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'clob', N'string', N'oracle', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'nclob', N'string', N'oracle', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'rowid', N'string', N'oracle', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'urowid', N'string', N'oracle', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'timestamp', N'datetime', N'oracle', N'datetime2')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'double', N'double', N'mongodb', N'float')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'string', N'string', N'mongodb', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'binary data', N'string', N'mongodb', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'object id', N'string', N'mongodb', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'boolean', N'int16', N'mongodb', N'bit')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'date', N'datetime', N'mongodb', N'datetime2')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'32-bit integer', N'int32', N'mongodb', N'int')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'timestamp', N'string', N'mongodb', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'64-bit integer', N'int64', N'mongodb', N'bigint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'decimal 128', N'double', N'mongodb', N'decimal')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'dbpointer', N'string', N'mongodb', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'javascript', N'string', N'mongodb', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'max key', N'string', N'mongodb', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'min key', N'string', N'mongodb', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'symbol', N'string', N'mongodb', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'regular expression', N'string', N'mongodb', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'undefined/null', N'string', N'mongodb', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'integer', N'int32', N'teradata', N'int')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'smallint', N'int16', N'teradata', N'smallint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'bigint', N'int64', N'teradata', N'bigint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'byteint', N'int16', N'teradata', N'smallint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'decimal', N'double', N'teradata', N'decimal')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'float', N'double', N'teradata', N'decimal')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'byte', N'byte[]', N'teradata', N'binary')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'varbyte', N'byte[]', N'teradata', N'varbinary')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'blob', N'byte[]', N'teradata', N'varbinary')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'char', N'string', N'teradata', N'nchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'clob', N'sting', N'teradata', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'varchar', N'sting', N'teradata', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'graphic', N'string', N'teradata', N'nchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'json', N'sting', N'teradata', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'vargraphic', N'sting', N'teradata', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'date', N'datetime', N'teradata', N'date')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'timestamp', N'datetime', N'teradata', N'datetime2')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'time', N'timespan', N'teradata', N'time')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'time with time zone', N'timespan', N'teradata', N'time')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'timestamp with time zone', N'timespan', N'teradata', N'time')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'datetime', N'datetime', N'json', N'date')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'decimal', N'decimal', N'json', N'decimal')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'guid', N'guid', N'json', N'Nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'int64', N'int64', N'json', N'bigint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'double', N'double', N'json', N'float')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'int16', N'int16', N'json', N'tinyint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'bit', N'int16', N'mysqlserver', N'bit')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'tinytext', N'string', N'mysqlserver', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'number(19)', N'int64', N'oracle', N'bigint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'char', N'string', N'oracle', N'char')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'date', N'datetime', N'oracle', N'datetime')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'number(10,2)', N'double', N'oracle', N'decimal')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'float', N'double', N'oracle', N'float')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'nchar', N'string', N'oracle', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'number(3)', N'int16', N'oracle', N'tinyint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'bit', N'string', N'salesforce', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'datetime', N'date', N'salesforce', N'datetime')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'double', N'double', N'salesforce', N'decimal')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'varchar', N'string', N'salesforce', N'varchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'numeric', N'double', N'sqlserver', N'decimal')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'int', N'int32', N'mysqlserver', N'int')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'smallint', N'int16', N'mysqlserver', N'smallint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'bigint', N'int64', N'mysqlserver', N'bigint')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'tinyint(1)', N'int16', N'mysqlserver', N'bit')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'float', N'double', N'mysqlserver', N'float')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'decimal', N'double', N'mysqlserver', N'decimal')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'longtext', N'string', N'mysqlserver', N'nchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'mediumtext', N'string', N'mysqlserver', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'varchar', N'string', N'mysqlserver', N'nvarchar')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'date', N'datetime', N'mysqlserver', N'date')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'datetime', N'datetime', N'mysqlserver', N'datetime')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'time', N'timespan', N'mysqlserver', N'time')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'timestamp', N'timespan', N'mysqlserver', N'timestamp')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'mediumblob', N'byte[]', N'mysqlserver', N'varbinary')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'binary', N'byte[]', N'mysqlserver', N'varbinary')
INSERT [elt].[TypeMap] ([SourceDataType], [InterimDataType], [SystemType], [SinkDataType]) VALUES (N'longblob', N'byte[]', N'mysqlserver', N'varbinary')
GO