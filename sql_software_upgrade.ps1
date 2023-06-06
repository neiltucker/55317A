C:\SQLServerFull\Setup.exe /INDICATEPROGRESS /IACCEPTSQLSERVERLICENSETERMS /Q /CONFIGURATIONFILE=C:\Classfiles\SQL_Software_Upgrade.ini
$UserName = "adminz"
$Password = ConvertTo-SecureString 'Pa$$w0rdPa$$w0rd' -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList ($UserName, $Password)
$args = "Restart-Service -Name MSSQLSERVER -Force"
Start-Process powershell.exe -Credential $Credential -ArgumentList $args
