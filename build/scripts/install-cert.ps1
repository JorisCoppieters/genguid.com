Param(
    $certPath = $null,
    $certName = $null
)
write-host $certPath
write-host $certName

if (-not $certPath) {
    throw "`$certPath not set"
}

if (-not $certName) {
    throw "`$certName not set"
}

$certStores = @("Cert:/LocalMachine/Root","Cert:/LocalMachine/CA","Cert:/LocalMachine/My","Cert:/CurrentUser/Root","Cert:/CurrentUser/CA","Cert:/CurrentUser/My")

foreach ($certStore in $certStores) {
    $thumbprints = (Get-ChildItem "$certStore" | Where {$_.FriendlyName -match $certName}).Thumbprint
    if ($thumbprints) {
        Write-Host "[Certificates] Removing certificates..." -f red
        foreach ($thumbprint in $thumbprints) {
            Remove-Item -path "$certStore/$thumbprint"
        }
    }
}

foreach ($certStore in $certStores) {
    $thumbprint = (Import-Certificate -filePath "$certPath" -certStoreLocation "$certStore").Thumbprint
    if ($thumbprint) {
        Write-Host "[Certificates] Installing certificate..." -f green
        $cert = Get-Item "$certStore/$thumbprint"
        $cert.FriendlyName = $certName
    }
}
