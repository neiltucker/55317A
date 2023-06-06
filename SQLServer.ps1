Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
Import-Module -Name SQLSERVER -Force
Set-Location SQLServer:\SQL\localhost
Invoke-SQLCMD -Inputfile c:\labfiles.55317\SQLServerConfig.sql -TrustServerCertificate

