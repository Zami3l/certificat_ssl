$User = [Security.Principal.WindowsIdentity]::GetCurrent()
$Role = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

# Vérification des privilèges
if(!$Role)
{
    Throw "Vous n'avez pas de privilèges suffisants."
    Start-Sleep -s 3
    Exit
}

Write-Host "`nCe script permet de créer un certificat SSL auto-signé."

$instance = Read-Host "`nVeuillez choisir le nom du certificat SSL auto-signé"
$motDePasse = Read-Host "Mot de passe à appliquer sur le certificat SSL auto-signé"

New-SelfSignedCertificate -CertStoreLocation cert:\LocalMachine\my -dnsname $instance -NotAfter (Get-Date).AddYears(100)
$pwd = ConvertTo-SecureString "$motDePasse" -asplainText -force
$file = "C:\windows\temp\$instance.pfx"
$key = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -match "$instance"} | Select-Object -ExpandProperty Thumbprint
Export-PFXCertificate -cert cert:\LocalMachine\My\$key -file $file -Password $pwd
Import-PfxCertificate -FilePath $file cert:\LocalMachine\root -Password $pwd

Write-Host "`n--------------------------------------------------"
Write-Host "`n `nAjout du certificat $instance terminé."
Write-Host "`n--------------------------------------------------"
