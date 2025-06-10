$scriptUrl = "https://raw.githubusercontent.com/Guwanus/pop/main/InstallAndConfigure_Intune.ps1"
$configUrl = "https://raw.githubusercontent.com/Guwanus/pop/main/config.json"
$tempPath = "$env:ProgramData\IntuneScript"
$scriptPath = Join-Path $tempPath "InstallAndConfigure_Intune.ps1"
$configPath = Join-Path $tempPath "config.json"

# Zorg dat map bestaat
New-Item -ItemType Directory -Path $tempPath -Force | Out-Null

# Download bestanden
Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
Invoke-WebRequest -Uri $configUrl -OutFile $configPath

# Voer script uit
powershell.exe -ExecutionPolicy Bypass -File $scriptPath -ConfigPath $configPath
