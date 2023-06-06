# This script configures the Hyper-V Machines used for the 55317 Course.
# Updates to class files can be found on GitHub (https://github.com/neiltucker/55317A). 
# This script will only work on computers that run Hyper-V 3.0 or higher and PowerShell 3.0 or higher.
# The Drive that corresponds to the $VMLOC variable should have at least 100GB of free space available.
# The Drive that corresponds to the $Labfiles variable should have at least 20GB of free space available.

# Variables
$SRV1 = "55317MIASQL"					# Name of VM
$SRVRAM = 2GB						# Minimum memory for VM
$SRVVHD = 120GB
$Labfiles = "C:\Labfiles.55317"			# Location of all installation files.  Avoid changing.
$SetupFiles = "55317A-ENU_PowerShellSetup.zip"
Expand-Archive $SetupFiles $Labfiles -Force -ErrorAction "SilentlyContinue"
$SRVISO = "C:\Labfiles.55317\WS2022.ISO"		# Name of Windows Server ISO
$SQLISO = "C:\Labfiles.55317\SQL2022.ISO"		# Name of SQL Server ISO
$VMLOC = "C:\HyperV"					# Change to drive where most free space is available
$Network1 = "Default Switch"				# If necessary, use existing Hyper-V switch for Internet access
$Network2 = "55317InternalNetwork"			# Internal Network Switch 
$VHDMP = "S:"
$StartTime = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"	# Time VM setup process started

# Install PowerShell Modules
If ((Get-PSRepository -Name PSGallery).InstallationPolicy = "Trusted") {Write-Output "PSGallery is already a trusted repository"} Else {Set-PSRepository -Name PSGallery -InstallationPolicy Trusted}
If (Get-PackageProvider -Name NuGet) {Write-Output "NuGet PackageProvider already installed."} Else {Install-PackageProvider -Name "NuGet" -Force -Confirm:$False}
If (Get-Module -ListAvailable -Name PowerShellGet) {Write-Output "PowerShellGet module already installed"} Else {Find-Module PowerShellGet -IncludeDependencies | Install-Module -Force}
If (Get-Module -ListAvailable -Name SQLServer) {Write-Output "SQLServer module already installed" ; Import-Module SQLServer} Else {Install-Module -Name SQLServer -AllowClobber -Force ; Import-Module -Name SQLServer}
Remove-Item -Recurse -Force $Labfiles\SqlServerModule -ErrorAction SilentlyContinue
New-Item -ItemType "Directory" -Path $Labfiles\SqlServerModule -Force
Save-Module -Name SqlServer -Path $Labfiles\SqlServerModule\
Remove-Item -Recurse -Force $Labfiles\PowerShellGet -ErrorAction SilentlyContinue
New-Item -ItemType "Directory" -Path $Labfiles\PowerShellGet -Force
Save-Module -Name PowerShellGet -Path $Labfiles\PowerShellGet

# Load HyperV Module
Write-Output "Load HyperV Module"
Get-ChildItem $PSHome\Modules -Recurse | UnBlock-File -ErrorAction SilentlyContinue
$HyperV = Get-Module Hyper-V
if ($HyperV -eq $Null) {Import-Module Hyper-V -ErrorAction SilentlyContinue}

# Copy Windows Server 2022 Files Needed to Configure Windows Features on VM
Write-Output "     *****     Copy Windows Server 2022 Files     *****"
$TPSRVISO = Test-Path $SRVISO ; If ($TPSRVISO -eq $False){cls ; "The Windows Server 2022 Files could not be found at $SRVISO.  Please check the setup instructions and start again." ; Start-Sleep 15 ; exit}
& $Labfiles\ws2022_Files.ps1

# Copy SQL Server 2022 Files
Write-Output "     *****     Copy SQL Server 2022 Setup Files    *****"
$TPSQLISO = Test-Path $SQLISO ; If ($TPSQLISO -eq $False){cls ; "The SQL Server 2022 Files could not be found at $SQLISO.  Please check the setup instructions and start again." ; Start-Sleep 15 ; exit}
& $Labfiles\SQL2022_Files.ps1

# Verify Setup Folders are named properly
$TPWS = Test-Path $Labfiles\Sources\SXS ; If ($TPWS -eq $False){cls ; "The Windows Server 2022 Files are not in $Labfiles\Sources\SXS.  Please check the setup instructions and start again." ; Start-Sleep 15 ; exit}

$VerifySQL = 0
Do {
$TPSQL = Test-Path $Labfiles\SQLServer\SQL2022 ; If ($TPSQL -eq $True) {$VerifySQL = 4} `
Else {$VerifySQL++ ; echo "Trying to Rename SQL Server Setup Folder" ; Start-Sleep 5 ; `
Rename-Item $Labfiles\SQLServer\CDROM1 $Labfiles\SQLServer\SQL2022 -PassThru -Force -ErrorAction SilentlyContinue ;}
}
While ($VerifySQL -le 3)
$TPSQL = Test-Path $Labfiles\SQLServer\SQL2022 ; If ($TPSQL -eq $False){cls ; "The SQL Server Files are not in $Labfiles\SQLServer\SQL2022.  Please check the setup instructions and start again." ; Start-Sleep 15 ; exit}

# Verify that the VMs do not already exist.
Write-Output "Verify that the VMs do not already exist"
$VMSRV1 = Get-VM $SRV1 -ErrorAction SilentlyContinue; If ($VMSRV1) {echo "***   The $SRV1 VM already exists.  Please delete it and its resources before using this script.   ***"; Start-Sleep 15 ; exit}
$TPLabfiles = Test-Path $Labfiles ; If ($TPLabfiles -eq $False){cls ; "The $Labfiles folder does not exist." ; "Please verify the location of the classroom setup files." ; Start-Sleep 15 ; exit}
$TPSRV1HD1 = Test-Path $VMLOC\$SRV1.vhdx ; If ($TPSRV1HD1 -eq $True){cls ; "The " + $SRV1 + " VHDX already exists.  Verify that the VMs are not already configured." ; Start-Sleep 15 ; exit}
$TPSRV1HD2 = Test-Path $VMLOC\Labfiles_$SRV1.vhdx ; If ($TPSRV1HD2 -eq $True){cls ; "The Labfiles_$SRV1 VHDX already exists.  Verify that the VMs are not already configured." ; Start-Sleep 15 ; exit}
remove-vmswitch $Network2 -force -erroraction silentlycontinue
MD $VMLOC -erroraction silentlycontinue

# Download AdventureWorks & AdventureWorksDW backup files
Write-Output "Download AdventureWorks & AdventureWorksDW backup files"
& $Labfiles\adventureworks_download.ps1
& $Labfiles\adventureworksdw_download.ps1

# Create VMs and get MAC Addresses for Network Adapters
Write-Output "Configure VM 55317MIASQL"
$SRV1 | new-vm -path $VMLOC -SwitchName $Network1
new-vmswitch $Network2 -SwitchType Internal
get-vm $SRV1 | add-vmnetworkadapter -switchname $Network2
get-vm $SRV1 | set-vmprocessor -Count 4 -Reserve 25 -Maximum 80
get-vm $SRV1 | set-vmmemory -dynamicmemoryenabled $true -MinimumBytes $SRVRAM -StartupBytes $SRVRAM -MaximumBytes 6GB
get-vm $SRV1 | Start-VM
Start-Sleep 10
$SRV1MAC = Get-VMNetWorkAdapter $SRV1 | Where {$_.SwitchName -eq $Network2} | Select MacAddress | Convertto-csv; $SRV1MAC[2] | Out-File $Labfiles\$SRV1.txt
$SRV1MAC1 = Get-Content $Labfiles\$SRV1.txt
get-vm $SRV1 | Stop-VM -Turnoff -Force

# Create and Mount Drives and Controllers
Write-Output "     *****     Create VHDX used for Labfiles     *****" 
& $Labfiles\labfiles.ps1
new-vhd -path $VMLOC\$SRV1.vhdx -size $SRVVHD
add-vmharddiskdrive -vmname $SRV1 -controllernumber 0 -controllertype ide -path $VMLOC\$SRV1.VHDX
add-vmharddiskdrive -vmname $SRV1 -controllernumber 0 -controllertype ide -path $VMLOC\Labfiles_$SRV1.VHDX
remove-vmdvddrive -controllernumber 1 -controllerlocation 0 -vmname $SRV1 -erroraction SilentlyContinue
add-vmdvddrive -controllernumber 1 -controllerlocation 0 -vmname $SRV1 -Path $SRVISO 
set-vmfloppydiskdrive $SRV1 $Labfiles\srv1install.vfd

# Configure VMs
start-vm $SRV1
Write-Output "Automated setup of virtual machine 55317MIASQL is now starting.  Progress can be checked in Hyper-V Manager.  The setup should be complete in one hour."
$et = Get-Date
$EndTime = $et.ToString("yyyy-MM-ddTHH:mm:ss")
$outputfile = "55317HyperVSetup" + $et.ToString("yyyyMMddHHmmss") + ".txt" 
Write-Output "Start Time:    $StartTime" > $Labfiles"\"$outputfile
Write-Output "End Time:      $EndTime" >> $Labfiles"\"$outputfile
Write-Output "VM Name:       $SRV1" >> $Labfiles"\"$outputfile
Write-Output "Contoso  MAC:  $SRV1MAC1" >> $Labfiles"\"$outputfile
Get-Content $Labfiles"\"$outputfile

