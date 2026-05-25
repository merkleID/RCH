$ErrorActionPreference = 'Stop'

$server      = '192.168.1.55'
$shareName   = 'NOME_SHARE'
$sharePath   = "\\$server\$shareName"
$driveLetter = 'S'
$username    = 'revents'
$password    = 'PASSWORD_HERE'

Write-Host 'Verifica delle unità di rete gia montate...'

# Rimuovi tutti i drive con lettera mappati a share di rete
$mappedDrives = Get-PSDrive -PSProvider FileSystem | Where-Object {
    $_.DisplayRoot -like '\\*'
}
foreach ($drive in $mappedDrives) {
    $name = '{0}:' -f $drive.Name
    Write-Host "Rimozione di $name -> $($drive.DisplayRoot)"
    cmd.exe /c "net use $name /delete /y" 2>$null | Out-Null
}

# Rimuovi anche eventuali sessioni "senza lettera" verso lo stesso server
Write-Host "Rimozione sessioni residue verso \\$server..."
cmd.exe /c "net use \\$server /delete /y" 2>$null | Out-Null

Write-Host "Connessione di $sharePath su $driveLetter`: come $username..."

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential     = New-Object System.Management.Automation.PSCredential($username, $securePassword)

New-PSDrive -Name $driveLetter `
            -PSProvider FileSystem `
            -Root $sharePath `
            -Credential $credential `
            -Persist `
            -Scope Global | Out-Null

Write-Host "Share montato correttamente come $driveLetter`:"
