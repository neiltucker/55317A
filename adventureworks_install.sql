USE [master]
RESTORE DATABASE [AdventureWorks2019] 
FROM  DISK = N'C:\Labfiles.55317\AdventureWorks2019.bak' 
WITH RECOVERY,  
MOVE 'AdventureWorks2019' TO 'C:\AdventureWorks\AdventureWorks2019.mdf',   
MOVE 'AdventureWorks2019_Log' TO 'C:\AdventureWorks\AdventureWorks2019_Log.ldf';
GO
GO
USE [AdventureWorks2019]
GO
ALTER AUTHORIZATION ON DATABASE::[AdventureWorks2019] TO [sa]
GO


