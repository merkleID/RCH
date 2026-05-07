# Script di verifica e ricreazione dello share di rete
# Repo: RCH - Network Share Health Check
# Username semplificato: luca

param(
    [string]$SharePath = "\\192.168.1.55\condivisione",
    [string]$DriveLetter = "Z",
    [string]$Username = "luca",
    [string]$Password = "PASSWORD_QUI",
    [string]$LogPath = "C:\Logs\ShareVerification.log"
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    $logDir = Split-Path $LogPath
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }
    
    Add-Content -Path $LogPath -Value $logEntry
    Write-Host $logEntry -ForegroundColor $(if ($Level -eq "ERROR") { "Red" } else { "Green" })
}

function Test-ShareConnectivity {
    param([string]$Path)
    
    try {
        $null = Test-Path -Path $Path -ErrorAction Stop
        Write-Log "Share raggiungibile: $Path" "INFO"
        return $true
    }
    catch {
        Write-Log "Share NON raggiungibile: $Path - Errore: $_" "ERROR"
        return $false
    }
}

function Disconnect-NetworkShare {
    param([string]$DriveLetter)
    
    try {
        $drive = "${DriveLetter}:"
        if (Test-Path -Path $drive) {
            net use $drive /delete /y
            Write-Log "Share disconnesso: $drive" "INFO"
            Start-Sleep -Seconds 2
            return $true
        }
    }
    catch {
        Write-Log "Errore durante disconnessione: $_" "ERROR"
        return $false
    }
}

function Connect-NetworkShare {
    param(
        [string]$SharePath,
        [string]$DriveLetter,
        [string]$Username,
        [string]$Password
    )
    
    try {
        $drive = "${DriveLetter}:"
        
        if (Test-Path -Path $drive) {
            Disconnect-NetworkShare -DriveLetter $DriveLetter
        }
        
        net use $drive $SharePath /user:$Username $Password /persistent:yes
        
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Share connesso con successo: $drive -> $SharePath" "INFO"
            return $true
        }
        else {
            Write-Log "Errore connessione share (exit code: $LASTEXITCODE)" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Errore durante connessione: $_" "ERROR"
        return $false
    }
}

Write-Log "=== Inizio verifica share ===" "INFO"
Write-Log "Target: $SharePath su $DriveLetter`:" "INFO"

if (Test-ShareConnectivity -Path $SharePath) {
    Write-Log "✓ Share è attivo e funzionante" "INFO"
    exit 0
}
else {
    Write-Log "✗ Share non raggiungibile - Avvio procedura di ricreazione" "ERROR"
    
    Disconnect-NetworkShare -DriveLetter $DriveLetter
    Start-Sleep -Seconds 3
    
    if (Connect-NetworkShare -SharePath $SharePath -DriveLetter $DriveLetter -Username $Username -Password $Password) {
        Write-Log "✓ Share ricreato con successo" "INFO"
        exit 0
    }
    else {
        Write-Log "✗ Fallimento: impossibile ricreare share" "ERROR"
        exit 1
    }
}
