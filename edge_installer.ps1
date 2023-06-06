$MicrosoftEdgeMSI = Join-Path C:\Classfiles MicrosoftEdgeEnterpriseX64.msi
Invoke-WebRequest 'http://go.microsoft.com/fwlink/?LinkID=2093437'  -OutFile $MicrosoftEdgeMSI
Start-Process $MicrosoftEdgeMSI -ArgumentList "/quiet /passive"
Start-Sleep 30


