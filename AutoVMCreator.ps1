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

    write-output "*** Installing Firefox ***"
    choco install firefox -y
    
    write-output "*** Installing LibreOffice ***"
    choco install libreoffice-fresh -y
    
    write-output "*** Installing Notepad++ ***"
    choco install notepadplusplus -y

    write-output "*** Installing Python ***"
    # Python 3.9.7 or less required for oletools 0.60
    choco install python --version 3.9.7 -y
    C:\Python39\python.exe -m pip install --upgrade pip
    
    write-output "*** Installing oletools and pycryptodome ***"
    C:\Python39\python.exe -m pip install oletools pycryptodome
    
    write-output "*** Installing Sysinternals ***"
    choco install sysinternals --params "/InstallDir:$Tools\Sysinternals" -y

    write-output "*** Installing KAPE ***"
    Invoke-WebRequest -Uri $KAPE_URL -OutFile kape.zip
    expand-archive -force kape.zip "$Tools"
    Set-Location "$Tools\KAPE"
    .\kape.exe --msource C:\ --mdest C:\ --module !!ToolSync
    Set-Location $Downloads
    Invoke-WebRequest -Uri $RegRipper_URL -OutFile regripper.zip
    expand-archive -force regripper.zip $Downloads
    Move-Item RegRipper3.0-master $Tools\KAPE\Modules\bin\regripper
    Invoke-WebRequest -Uri $TlnTools_URL -OutFile tlntools.zip
    expand-archive -force tlntools.zip $Downloads
    Move-Item Tools-master\exe $Tools\KAPE\Modules\bin\tln_tools
    Invoke-WebRequest -Uri $KAPETimelineTools_URL -OutFile kape_timeline.zip
    expand-archive -force kape_timeline.zip $Downloads
    Move-Item KAPE_Tools-master\executables\* $Tools\KAPE\Modules\bin\tln_tools
    
    write-output "*** Installing FTK Imager ***"
    Invoke-WebRequest -Uri $FTKImager_URL -OutFile ftkimager.exe
    Start-Process ftkimager.exe -argumentlist "/S /v/qn" -wait
    move-item "c:\users\public\desktop\AccessData FTK Imager.lnk" "$Tools\FTK Imager.lnk"
    
    write-output "*** Installing Autopsy ***"
    choco install autopsy -y
    move-item "c:\users\public\desktop\Autopsy*.lnk" "$Tools\Autopsy.lnk"
    
    write-output "*** Installing Volatility ***"
    C:\Python39\python.exe -m pip install volatility3
    Invoke-WebRequest -Uri $VolWin_URL -OutFile C:\Python39\Lib\site-packages\volatility3\symbols\windows.zip
    Invoke-WebRequest -Uri $VolMac_URL -OutFile C:\Python39\Lib\site-packages\volatility3\symbols\mac.zip
    Invoke-WebRequest -Uri $VolLin_URL -OutFile C:\Python39\Lib\site-packages\volatility3\symbols\linux.zip
    
    write-output "*** Installing dnSpy ***"
    choco install dnspyex -y
    copy-item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\dnspy.lnk" $Tools
    
    write-output "*** Installing Wireshark ***"
    choco install wireshark -y
    copy-item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\wireshark.lnk" $Tools

    # Manual steps required (AKA I have no idea how to automate installing/configuring these)
    write-output "*** Installing 7-Zip ***"
    choco install 7zip -y
    read-host "Follow these steps:
    1. Open 7-zip
    2. Click on Tools, Options, System Tab
    3. Click the + button above All Users
    4. Click OK, then close 7-Zip
    Press Enter to open 7-Zip"
    start-process "C:\Program Files\7-Zip\7zfm.exe" -wait
    read-host "Press Enter once the steps above are complete"
    
    write-output "*** Installing Arsenal Image Mounter ***"
    read-host "Follow these steps:
    1. Use the web browser to download the latest Arsenal Image Mounter.
    2. Unzip the contents into the $Tools folder.
    3. Create a shortcut to ArsenalImageMounter.exe in the $Tools folder.
    Press Enter to open the browser"
    start-process $AIM_URL
    read-host "Press Enter once the steps above are complete"
    
    write-output "*** Installing CyberChef ***"
    read-host "Follow these steps:
    1. Use the web browser to download the latest CyberChef.
    2. Unzip the contents into the $Tools\Cyberchef folder.
    3. Create a shortcut to Cyberchef_v#.#.#.html in the $Tools folder.
    Press Enter to open the browser"
    start-process $CyberChef_URL
    read-host "Press Enter once the steps above are complete"
    
    write-output "*** Installing Floss ***"
    read-host "Follow these steps:
    1. Use the web browser to download the latest Floss for Windows.
    2. Unzip the contents directly into the $Tools folder.
    Press Enter to open the browser"
    start-process $Floss_URL
    read-host "Press Enter once the steps above are complete"
    
    write-output "*** Installing PE Detective ***"
    Invoke-WebRequest -Uri $PEDetective_URL -OutFile pedetective.zip
    expand-archive -force pedetective.zip "$Tools\PE Detective"
    read-host "Follow these steps:
    1. Create a shortcut to PE Detective.exe in the $Tools folder.
    Press Enter once the step above is complete"
    
    write-output "*** Installing PE-bear ***"
    read-host "Follow these steps:
    1. Use the web browser to download the latest PE-bear_*_x64_win_vs17.zip.
    2. Unzip the contents into the $Tools\PE-bear folder.
    3. Create a shortcut to PE-bear.exe in the $Tools folder.
    Press Enter to open the browser"
    start-process $PEbear_URL
    read-host "Press Enter once the steps above are complete"
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

Write-Output "`nDFIR Virtual Machine setup has been completed!"
