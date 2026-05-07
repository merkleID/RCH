# RCH - Network Share Health Check

PowerShell script per verificare la connettività di uno share di rete (SMB) e ricrearlo automaticamente se non raggiungibile.

## Descrizione

Lo script:
- Verifica se uno share di rete è raggiungibile
- Se attivo, termina con successo
- Se non raggiungibile:
  - Disconnette il drive mapping
  - Lo ricrea con le credenziali fornite
  - Salva i log in `C:\Logs\ShareVerification.log`

## Configurazione

Modifica questi parametri nello script:

```powershell
$SharePath = "\\192.168.1.55\cartella"    # Indirizzo share
$DriveLetter = "Z"                         # Drive letter (Z:, Y:, ecc.)
$Username = "luca"                         # Username
$Password = "PASSWORD_QUI"                 # Password (vedi sicurezza)
$LogPath = "C:\Logs\ShareVerification.log" # Percorso log
```

## Utilizzo

### Esecuzione manuale
```powershell
.\Verify-NetworkShare.ps1
```

### Pianificazione automatica (Task Scheduler)
```powershell
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File C:\path\to\Verify-NetworkShare.ps1"
$trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 5) -AtStartup
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "VerifyNetworkShare" -RunLevel Highest
```

## Sicurezza

⚠️ **Non mettere la password in chiaro nello script.**

Opzioni consigliate:

### Credential Manager
```powershell
# Setup (una sola volta)
$cred = Get-Credential
$cred | Export-Clixml -Path "C:\Secure\credential.xml"

# Nello script
$cred = Import-Clixml -Path "C:\Secure\credential.xml"
$Password = $cred.GetNetworkCredential().Password
```

### Variabili d'ambiente
```powershell
[Environment]::SetEnvironmentVariable("NET_PASSWORD", "tuaPassword", "User")
$Password = [Environment]::GetEnvironmentVariable("NET_PASSWORD", "User")
```

## Exit Codes

- `0` — Share attivo o ricreato con successo
- `1` — Errore durante ricreazione

## Log

I log sono salvati in `C:\Logs\ShareVerification.log` con timestamp e livello (INFO/ERROR).

---

**Autore:** CISO - Merkle-ID  
**Licenza:** MIT
