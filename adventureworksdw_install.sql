USE [master]
RESTORE DATABASE [AdventureWorksDW2019] 
FROM  DISK = N'C:\Labfiles.55317\AdventureWorksDW2019.bak' 
WITH RECOVERY,  
MOVE 'AdventureWorksDW2019' TO 'C:\AdventureWorks\AdventureWorksDW2019.mdf',   
MOVE 'AdventureWorksDW2019_Log' TO 'C:\AdventureWorks\AdventureWorksDW2019_Log.ldf';
GO
GO
USE [AdventureWorksDW2019]
GO
ALTER AUTHORIZATION ON DATABASE::[AdventureWorksDW2019] TO [sa]
GO


