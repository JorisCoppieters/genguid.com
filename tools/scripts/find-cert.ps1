Param(
    $certPath = $null,
    $certName = $null
)

if (-not $certPath) {
    throw "`$certPath not set"
}

if (-not $certName) {
    throw "`$certName not set"
}

$certStores = @("Cert:/LocalMachine/Root","Cert:/LocalMachine/CA","Cert:/LocalMachine/My","Cert:/CurrentUser/Root","Cert:/CurrentUser/CA","Cert:/CurrentUser/My")

$foundCert = $false
foreach ($certStore in $certStores) {
    $foundCert = (Get-ChildItem "$certStore" | Where {$_.FriendlyName -match $certName}).Thumbprint
    if ($foundCert) {
        Break
    }
}

If ($foundCert) {
    Write-Host "true"
}
