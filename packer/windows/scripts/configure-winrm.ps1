<powershell>
# Enable WinRM over HTTPS for Packer provisioning
# This runs as EC2 user data on the build instance

# Set network profile to private
Set-NetConnectionProfile -NetworkCategory Private -ErrorAction SilentlyContinue

# Enable PSRemoting
Enable-PSRemoting -Force -SkipNetworkProfileCheck

# Configure WinRM base settings
winrm quickconfig -q
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'

# Create self-signed certificate for HTTPS listener
$hostname = [System.Net.Dns]::GetHostName()
$cert = New-SelfSignedCertificate -DnsName $hostname -CertStoreLocation Cert:\LocalMachine\My

# Create HTTPS listener
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$hostname`";CertificateThumbprint=`"$($cert.Thumbprint)`"}"

# Remove HTTP listener (only use HTTPS)
winrm delete winrm/config/Listener?Address=*+Transport=HTTP 2>$null

# Disable unencrypted traffic
winrm set winrm/config/service '@{AllowUnencrypted="false"}'

# Set WinRM service to auto-start
Set-Service -Name WinRM -StartupType Automatic
Restart-Service WinRM

# Open WinRM HTTPS port in Windows Firewall
netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986

# Set Administrator password for Packer WinRM connection
$admin = [ADSI]("WinNT://./Administrator,user")
$admin.SetPassword("${admin_password}")
</powershell>
