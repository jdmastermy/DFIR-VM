<#
.Synopsis
    Construct a Digital Forensics and Incident Response (DFIR) VM.
.DESCRIPTION
    Sets up Windows and deploys software essential for a DFIR VM.
.EXAMPLE
    PS C:\> .\AutoVMCreator.ps1
#>

# Script Parameters
param(
    [string]$ToolPath = Join-Path $env:USERPROFILE "Desktop\Tools",
    [string]$DownloadPath = Join-Path $env:USERPROFILE "Downloads",

    # URLs for various tools
    [string]$OOShutup_URL = "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe",
    [string]$OOShutupConfig_URL = "https://raw.githubusercontent.com/netsecninja/DFIR-Lab/main/ooshutup10.cfg",
    [string]$Chocolatey_URL = "https://community.chocolatey.org/install.ps1",
    [string]$EZTools_URL = "https://f001.backblazeb2.com/file/EricZimmermanTools/Get-ZimmermanTools.zip",
    [string]$KAPE_URL = "https://s3.amazonaws.com/cyb-us-prd-kape/kape.zip",
    [string]$RegRipper_URL = "https://github.com/keydet89/RegRipper3.0/archive/refs/heads/master.zip",
    [string]$TlnTools_URL = "https://github.com/keydet89/Tools/archive/refs/heads/master.zip",
    [string]$KAPETimelineTools_URL = "https://github.com/mdegrazia/KAPE_Tools/archive/refs/heads/master.zip",
    [string]$FTKImager_URL = "https://ad-exe.s3.amazonaws.com/Imgr/AccessData_FTK_Imager_4.7.0.19.exe",
    [string]$AIM_URL = "https://arsenalrecon.com/downloads/",
    [string]$VolWin_URL = "https://downloads.volatilityfoundation.org/volatility3/symbols/windows.zip",
    [string]$VolMac_URL = "https://downloads.volatilityfoundation.org/volatility3/symbols/mac.zip",
    [string]$VolLin_URL = "https://downloads.volatilityfoundation.org/volatility3/symbols/linux.zip",
    [string]$CyberChef_URL = "https://gchq.github.io/CyberChef",
    [string]$Floss_URL = "https://github.com/mandiant/flare-floss/releases/latest",
    [string]$PEDetective_URL = "https://ntcore.com/files/PE_Detective.zip",
    [string]$PEbear_URL = "https://github.com/hasherezade/pe-bear-releases/releases/latest"
)

function DownloadAndRun($url, $output) {
    Invoke-WebRequest -Uri $url -OutFile $output
    Start-Process -FilePath $output -Wait
}

function ConfigureWindows {
    Write-Output "Setting up Time Zone..."
    Set-TimeZone "UTC"
    # set your own timezone, use command "Get-TimeZone -ListAvailable" to check your timezone

    Write-Output "Creating Tools directory at $ToolPath..."
    New-Item $ToolPath -ItemType Directory -Force | Out-Null
}

function InstallSoftware {
    Write-Output "Deploying O&OShutUp..."
    DownloadAndRun $OOShutup_URL "OOSU10.exe"
    Invoke-WebRequest -Uri $OOShutupConfig_URL -OutFile "ooshutup10.cfg"
    Start-Process ".\OOSU10.exe" -ArgumentList "ooshutup10.cfg /quiet" -Wait

    Write-Output "Deploying Chocolatey..."
    DownloadAndRun $Chocolatey_URL "install.ps1"

    #... [add the rest of the installations here]
}

function CleanUp {
    Write-Output "Cleaning up temporary files..."
    Remove-Item $DownloadPath\* -Recurse -ErrorAction SilentlyContinue
    Clear-RecycleBin -Force
}

# Main Script Execution
Write-Output "Constructing DFIR lab..."
$UserPassword = Read-Host "Provide the password for $env:username"

ConfigureWindows
InstallSoftware
CleanUp

Write-Output "`nDFIR lab setup has been completed!"
