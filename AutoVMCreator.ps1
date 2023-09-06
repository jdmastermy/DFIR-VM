<#
.Synopsis
    Construct a Digital Forensics and Incident Response (DFIR) lab.
.DESCRIPTION
    Sets up Windows and deploys software essential for a DFIR lab.
.EXAMPLE
    PS C:\> .\Setup-DFIRLab.ps1
#>

# Script Parameters
param(
    [string]$ToolPath = Join-Path $env:USERPROFILE "Desktop\Tools",
    [string]$DownloadPath = Join-Path $env:USERPROFILE "Downloads",

    # URLs for various tools
    [string]$OOShutup_URL = "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe",
    [string]$OOShutupConfig_URL = "https://raw.githubusercontent.com/netsecninja/DFIR-Lab/main/ooshutup10.cfg",
    [string]$Chocolatey_URL = "https://community.chocolatey.org/install.ps1",
    #... [add the rest of the URLs here]
)

function DownloadAndRun($url, $output) {
    Invoke-WebRequest -Uri $url -OutFile $output
    Start-Process -FilePath $output -Wait
}

function ConfigureWindows {
    Write-Output "Setting up Time Zone..."
    Set-TimeZone "Mountain Standard Time"

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
