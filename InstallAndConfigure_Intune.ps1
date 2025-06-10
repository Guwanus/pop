# InstallAndConfigure_Intune.ps1
# Automatisch software installeren via Intune met Chocolatey en configuratiebestand

param (
    [string]$ConfigPath = "config.json",
    [string]$LogPath = "C:\Logs\IntuneInstallLog.txt"
)

# Zorg dat de logmap bestaat
$logDir = Split-Path $LogPath
if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Functie om te loggen
function Write-Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogPath -Append -Encoding utf8
}

# Start logging
Write-Log "========== SCRIPT GESTART =========="

# Controleer of Chocolatey is geïnstalleerd
if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Write-Log "Chocolatey niet gevonden. Installatie wordt gestart..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-Log "Chocolatey succesvol geïnstalleerd."
    } catch {
        $errMsg = "Fout bij installatie van Chocolatey:`n$($_.Exception.Message)"
        Write-Log $errMsg
        exit 1
    }
} else {
    Write-Log "Chocolatey is al geïnstalleerd."
}

# Lees configuratiebestand
if (-not (Test-Path $ConfigPath)) {
    Write-Log "Configuratiebestand niet gevonden: $ConfigPath"
    exit 1
}

try {
    $configContent = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    $packages = $configContent.packages
    Write-Log "Gevonden pakketten in configuratie: $($packages -join ', ')"
} catch {
    $errMsg = "Fout bij lezen van configuratiebestand:`n$($_.Exception.Message)"
    Write-Log $errMsg
    exit 1
}

# Installeer pakketten
foreach ($pkg in $packages) {
    Write-Log "Probeer installatie van pakket: $pkg"
    try {
        choco install $pkg -y --no-progress
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Installatie van $pkg geslaagd."
        } else {
            Write-Log "Installatie van $pkg mislukt. Exitcode: $LASTEXITCODE"
        }
    } catch {
        $errMsg = "Fout bij installatie van ${pkg}:`n$($_.Exception.Message)"
        Write-Log $errMsg
    }
}

Write-Log "========== SCRIPT VOLTOOID =========="
