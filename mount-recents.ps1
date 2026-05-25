$ErrorActionPreference = 'Stop'

$sharePath = '\\192.168.1.55\NOME_SHARE'
$driveLetter = 'S:'
$username = 'revents'
$password = 'PASSWORD_HERE'

Write-Host 'Verifica delle unità di rete gia montate...'

$mappedDrives = Get-PSDrive -PSProvider FileSystem | Where-Object {
    $_.DisplayRoot -like '\\*'
}

foreach ($drive in $mappedDrives) {
    $name = '{0}:' -f $drive.Name
    Write-Host "Rimozione di $name -> $($drive.DisplayRoot)"
    cmd.exe /c "net use $name /delete /y" | Out-Null
}

Write-Host "Connessione di $sharePath su $driveLetter come $username..."
cmd.exe /c "net use $driveLetter $sharePath /user:$username $password /persistent:yes" | Out-Null

Write-Host "Share montato correttamente come $driveLetter"
