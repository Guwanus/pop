# InstallAndConfigure_Intune.ps1
# PowerShell script for Intune deployment using Chocolatey

$LogPath = "C:\Logs\IntuneInstallLog.txt"
$logDir = Split-Path $LogPath

# Ensure log directory exists
if (-not (Test-Path -Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Function to write log entries
function Write-Log {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogPath -Append -Encoding utf8
}

Write-Log "========== SCRIPT STARTED =========="

# Install Chocolatey if not already installed
if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    Write-Log "Chocolatey not found. Installing..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    try {
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-Log "Chocolatey installation completed."
    } catch {
        Write-Log ("Chocolatey installation failed: " + $error[0])
        exit 1
    }
} else {
    Write-Log "Chocolatey is already installed."
}

# List of packages to install
$packages = @("googlechrome", "7zip", "vlc")

foreach ($pkg in $packages) {
    Write-Log "Installing $pkg..."
    try {
        choco install $pkg -y --no-progress
        if ($LASTEXITCODE -eq 0) {
            Write-Log "$pkg installed successfully."
        } else {
            Write-Log "$pkg installation returned exit code $LASTEXITCODE"
        }
    } catch {
        Write-Log ("Exception during installation of " + $pkg + ": " + $error[0])
    }
}

Write-Log "========== SCRIPT COMPLETED =========="
